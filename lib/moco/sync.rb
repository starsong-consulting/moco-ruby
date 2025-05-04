# frozen_string_literal: true

require "fuzzy_match"
require_relative "client"

module MOCO
  # Match and map projects and tasks between MOCO instances and sync activities
  class Sync
    attr_reader :project_mapping, :task_mapping, :source_projects, :target_projects
    attr_accessor :project_match_threshold, :task_match_threshold, :dry_run, :debug

    def initialize(source_client, target_client, **args)
      @source = source_client
      @target = target_client
      @project_match_threshold = args.fetch(:project_match_threshold, 0.8)
      @task_match_threshold = args.fetch(:task_match_threshold, 0.45)
      @filters = args.fetch(:filters, {})
      @dry_run = args.fetch(:dry_run, false)
      @debug = args.fetch(:debug, false)

      @project_mapping = {}
      @task_mapping = {}

      fetch_assigned_projects
      build_initial_mappings
    end

    # rubocop:todo Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def sync(&callbacks)
      results = []

      source_activity_filters = @filters.fetch(:source, {})
      source_activities_r = @source.activities.where(source_activity_filters).all
      debug_log "Fetched #{source_activities_r.size} source activities"

      # Log source activities for debugging
      debug_log "Source activities:"
      source_activities_r.each do |activity|
        debug_log "  Source Activity: #{activity.id}, Date: #{activity.date}, Project: #{activity.project&.id} (#{activity.project&.name}), Task: #{activity.task&.id} (#{activity.task&.name}), Hours: #{activity.hours}, Description: #{activity.description}, Remote ID: #{activity.remote_id}"

        # Also log the expected target activity for each source activity
        begin
          expected = get_expected_target_activity(activity)
          if expected
            project_id = expected.project&.id rescue "N/A"
            task_id = expected.task&.id rescue "N/A"
            remote_id = expected.instance_variable_get(:@attributes)[:remote_id] rescue "N/A"
            debug_log "    Expected Target: Project: #{project_id}, Task: #{task_id}, Remote ID: #{remote_id}"
          end
        rescue => e
          debug_log "    Error getting expected target: #{e.message}"
        end
      end

      target_activity_filters = @filters.fetch(:target, {})
      target_activities_r = @target.activities.where(target_activity_filters).all
      debug_log "Fetched #{target_activities_r.size} target activities"

      # Log target activities for debugging
      debug_log "Target activities:"
      target_activities_r.each do |activity|
        debug_log "  Target Activity: #{activity.id}, Date: #{activity.date}, Project: #{activity.project&.id} (#{activity.project&.name}), Task: #{activity.task&.id} (#{activity.task&.name}), Hours: #{activity.hours}, Description: #{activity.description}, Remote ID: #{activity.remote_id}"
      end

      # Group activities by date and then by project_id for consistent lookups
      source_activities_grouped = source_activities_r.group_by(&:date).transform_values do |activities|
        activities.group_by { |a| a.project&.id } # Group by project ID
      end
      target_activities_grouped = target_activities_r.group_by(&:date).transform_values do |activities|
        activities.group_by { |a| a.project&.id } # Group by project ID
      end

      used_source_activities = []
      used_target_activities = []

      debug_log "Starting main sync loop..."
      source_activities_grouped.each do |date, activities_by_project_id|
        debug_log "Processing date: #{date}"
        activities_by_project_id.each do |source_project_id, source_activities|
          debug_log "  Processing source project ID: #{source_project_id} (#{source_activities.count} activities)"
          # Find the corresponding target project ID using the mapping
          target_project_object = @project_mapping[source_project_id]
          unless target_project_object
            debug_log "    Skipping - Source project ID #{source_project_id} not mapped."
            next
          end

          target_project_id = target_project_object.id
          # Fetch target activities using the target project ID
          target_activities = target_activities_grouped.fetch(date, {}).fetch(target_project_id, [])
          debug_log "    Found #{target_activities.count} target activities for target project ID: #{target_project_id}"

          if source_activities.empty? || target_activities.empty?
            debug_log "    Skipping - No source or target activities for this date/project pair."
            next
          end

          matches = calculate_matches(source_activities, target_activities)
          debug_log "    Calculated #{matches.count} potential matches."
          matches.sort_by! { |match| -match[:score] }

          debug_log "    Entering matches loop..."
          matches.each do |match|
            source_activity, target_activity = match[:activity]
            score = match[:score]
            debug_log "      Match Pair: Score=#{score}, Source=#{source_activity.id}, Target=#{target_activity.id}"

            if used_source_activities.include?(source_activity) || used_target_activities.include?(target_activity)
              debug_log "        Skipping match pair - already used: Source used=#{used_source_activities.include?(source_activity)}, Target used=#{used_target_activities.include?(target_activity)}"
              next
            end

            best_score = score # Since we sorted, this is the best score for this unused pair
            best_match = target_activity
            expected_target_activity = get_expected_target_activity(source_activity)
            debug_log "        Processing best score #{best_score} for Source=#{source_activity.id}"

            case best_score
            when 100
              debug_log "          Case 100: Equal"
              # 100 - perfect match found, nothing needs doing
              callbacks&.call(:equal, source_activity, expected_target_activity)
              # Mark both as used
              debug_log "            Marking Source=#{source_activity.id} and Target=#{target_activity.id} as used."
              used_source_activities << source_activity
              used_target_activities << target_activity
            when 60...100
              debug_log "          Case 60-99: Update"
              # >=60 <100 - match with some differences
              expected_target_activity.to_h.except(:id, :user, :customer).each do |k, v|
                debug_log "            Updating attribute #{k} on Target=#{target_activity.id}"
                best_match.send("#{k}=", v)
              end
              callbacks&.call(:update, source_activity, best_match)
              unless @dry_run
                debug_log "            Executing API update for Target=#{target_activity.id}"
                results << @target.activities.update(best_match.id, best_match.attributes) # Pass ID and attributes
                callbacks&.call(:updated, source_activity, best_match, results.last)
              end
              # Mark both as used
              debug_log "            Marking Source=#{source_activity.id} and Target=#{target_activity.id} as used."
              used_source_activities << source_activity
              used_target_activities << target_activity
            when 0...60
              debug_log "          Case 0-59: Low score, doing nothing for this pair."
              # <60 - Low score for this specific pair. Do nothing here.
              # Creation is handled later if source_activity remains unused.
              nil # Explicitly do nothing
            end
            # Only mark activities as used if score >= 60 (handled within the case branches above)
          end
          debug_log "    Finished matches loop."
        end
        debug_log "  Finished processing project IDs for date #{date}."
      end
      debug_log "Finished main sync loop."

      # Second loop: Create source activities that were never used (i.e., had no match >= 60)
      debug_log "Starting creation loop..."
      source_activities_r.each do |source_activity|
        if used_source_activities.include?(source_activity)
          debug_log "  Skipping creation for Source=#{source_activity.id} - already used."
          next
        end
        # Use safe navigation in case project is nil
        source_project_id = source_activity.project&.id
        unless @project_mapping[source_project_id]
          debug_log "  Skipping creation for Source=#{source_activity.id} - project #{source_project_id} not mapped."
          next
        end

        debug_log "  Processing creation for Source=#{source_activity.id}"
        expected_target_activity = get_expected_target_activity(source_activity)
        callbacks&.call(:create, source_activity, expected_target_activity)
        next if @dry_run

        debug_log "    Executing API create."
        # Pass attributes hash to create
        created_activity = @target.activities.create(expected_target_activity.attributes)
        results << created_activity
        # Pass the actual created activity object to the callback
        callbacks&.call(:created, source_activity, created_activity, results.last)
      end
      debug_log "Finished creation loop."

      results
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    def debug_log(message)
      warn "[SYNC DEBUG] #{message}" if @debug
    end

    def get_expected_target_activity(source_activity)
      # Create a duplicate of the source activity
      new_activity = source_activity.dup

      # Get the attributes hash
      attrs = new_activity.instance_variable_get(:@attributes)

      # Store the mapped task and project objects for reference
      mapped_task = @task_mapping[source_activity.task&.id]
      mapped_project = @project_mapping[source_activity.project&.id]

      # Set the task_id and project_id attributes instead of the full objects
      attrs[:task_id] = mapped_task.id if mapped_task
      attrs[:project_id] = mapped_project.id if mapped_project

      # Set remote_id to the source activity ID for future matching
      attrs[:remote_id] = source_activity.id.to_s

      # Remove the full objects from the attributes hash
      attrs.delete(:task)
      attrs.delete(:project)

      # Return the modified activity
      new_activity
    end

    def calculate_matches(source_activities, target_activities)
      matches = []
      
      source_activities.each do |source_activity|
        target_activities.each do |target_activity|
          # First check if this is a previously synced activity by comparing IDs directly
          if target_activity.respond_to?(:remote_id) && 
             target_activity.remote_id.to_s == source_activity.id.to_s
            debug_log "Direct match found: target.remote_id=#{target_activity.remote_id} matches source.id=#{source_activity.id}" if @debug
            matches << { activity: [source_activity, target_activity], score: 100 }
          else
            # If no direct match, use the regular scoring method
            score = score_activity_match(get_expected_target_activity(source_activity), target_activity)
            matches << { activity: [source_activity, target_activity], score: }
          end
        end
      end
      
      matches
    end

    def clamped_factored_diff_score(a, b, cmin = 0.0, cmax = 7.0, factor = 0.5)
      difference = (a - b).abs.clamp(cmin, cmax)
      normalized_difference = difference / cmax
      sublinear_factor = normalized_difference**factor
      score = 1 - sublinear_factor
      [0.0, score].max
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    def score_activity_match(a, b)
      # Must be same project
      return 0 if a.project != b.project

      # Check for exact ID match (for activities that were previously synced)
      # This is the most important check and overrides all others
      if a.id.to_s == b.remote_id.to_s || b.id.to_s == a.remote_id.to_s
        debug_log "Found exact ID match between #{a.id} and #{b.id}" if @debug
        return 100
      end

      # Check for exact ID match in remote_id field
      if a.remote_id.to_s == b.id.to_s || b.remote_id.to_s == a.id.to_s
        debug_log "Found exact ID match in remote_id: a.remote_id=#{a.remote_id}, b.id=#{b.id}" if @debug
        return 100
      end

      # Additional check for remote_id in attributes hash
      begin
        a_remote_id = a.instance_variable_get(:@attributes)[:remote_id].to_s rescue nil
        b_remote_id = b.instance_variable_get(:@attributes)[:remote_id].to_s rescue nil
        
        if (a_remote_id && !a_remote_id.empty? && a_remote_id == b.id.to_s) || 
           (b_remote_id && !b_remote_id.empty? && b_remote_id == a.id.to_s)
          debug_log "Found exact ID match in attributes hash: a.attributes[:remote_id]=#{a_remote_id}, b.id=#{b.id}" if @debug
          return 100
        end
      rescue => e
        debug_log "Error checking remote_id in attributes: #{e.message}" if @debug
      end

      # Date comparison - must be same date
      # Convert to string for comparison to handle different date object types
      # and normalize format to YYYY-MM-DD
      debug_log "Raw dates: a.date=#{a.date.inspect} (#{a.date.class}), b.date=#{b.date.inspect} (#{b.date.class})" if @debug

      # Normalize dates to YYYY-MM-DD format
      a_date = normalize_date(a.date)
      b_date = normalize_date(b.date)

      debug_log "Normalized dates: a_date=#{a_date}, b_date=#{b_date}" if @debug

      if a_date != b_date
        debug_log "Date mismatch: #{a_date} vs #{b_date}" if @debug
        return 0
      end

      score = 0

      # Task matching is important (30 points)
      if a.task&.id == b.task&.id
        score += 30
        debug_log "Task match: +30 points" if @debug
      end

      # Description matching (up to 30 points)
      if a.description.to_s.strip.empty? && b.description.to_s.strip.empty?
        # Both empty descriptions - consider it a match for this attribute
        score += 30
        debug_log "Empty description match: +30 points" if @debug
      else
        # Use fuzzy matching for non-empty descriptions
        _, description_match_score = FuzzyMatch.new([a.description.to_s]).find_with_score(b.description.to_s)
        if description_match_score
          desc_points = (description_match_score * 30.0).to_i
          score += desc_points
          debug_log "Description match (#{description_match_score}): +#{desc_points} points" if @debug
        end
      end

      # Hours matching (up to 40 points)
      # Exact hour match gets full points
      if a.hours == b.hours
        score += 40
        debug_log "Exact hours match: +40 points" if @debug
      else
        # Otherwise use the clamped difference score
        hours_points = (clamped_factored_diff_score(a.hours, b.hours) * 40.0).to_i
        score += hours_points
        debug_log "Hours similarity (#{a.hours} vs #{b.hours}): +#{hours_points} points" if @debug
      end

      debug_log "Final score for #{a.id} vs #{b.id}: #{score}" if @debug

      score
    end

    # Helper method to normalize dates to YYYY-MM-DD format
    def normalize_date(date_value)
      return nil if date_value.nil?

      date_str = date_value.to_s

      # First try to extract YYYY-MM-DD from ISO format
      date_str = date_str.split("T").first.strip if date_str.include?("T")

      # Handle different date formats
      begin
        # Try to parse as Date object if it's not already in YYYY-MM-DD format
        date_str = Date.parse(date_str).strftime("%Y-%m-%d") unless date_str =~ /^\d{4}-\d{2}-\d{2}$/
      rescue StandardError => e
        debug_log "Error normalizing date '#{date_str}': #{e.message}" if @debug
        # If parsing fails, return the original string
      end

      date_str
    end

    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength

    def fetch_assigned_projects
      # Use .projects.assigned for the source, standard .projects for the target
      source_filters = @filters.fetch(:source, {}).merge(active: "true")
      # Get the proxy, then fetch all results into the instance variable
      @source_projects = @source.projects.assigned.where(source_filters).all
      debug_log "Found #{@source_projects.size} source projects:"
      @source_projects.each do |project|
        debug_log "  Source Project: #{project.id} - #{project.name} (#{project.identifier})"
        debug_log "    Tasks:"
        project.tasks.each do |task|
          debug_log "      Task: #{task.id} - #{task.name}"
        end
      end

      target_filters = @filters.fetch(:target, {}).merge(active: "true")
      # Get the proxy, then fetch all results into the instance variable
      @target_projects = @target.projects.where(target_filters).all
      debug_log "Found #{@target_projects.size} target projects:"
      @target_projects.each do |project|
        debug_log "  Target Project: #{project.id} - #{project.name} (#{project.identifier})"
        debug_log "    Tasks:"
        project.tasks.each do |task|
          debug_log "      Task: #{task.id} - #{task.name}"
        end
      end

      # NOTE: The @source_projects and @target_projects are now Arrays of entities,
      #       not CollectionProxy or EntityCollection objects.
    end

    def build_initial_mappings
      @target_projects.each do |target_project|
        source_project = match_project(target_project)
        next unless source_project

        @project_mapping[source_project.id] = target_project
        debug_log "Mapped source project #{source_project.id} (#{source_project.name}) to target project #{target_project.id} (#{target_project.name})"

        target_project.tasks.each do |target_task|
          source_task = match_task(target_task, source_project)
          if source_task
            @task_mapping[source_task.id] = target_task
            debug_log "  Mapped source task #{source_task.id} (#{source_task.name}) to target task #{target_task.id} (#{target_task.name})"
          else
            debug_log "  No matching source task found for target task #{target_task.id} (#{target_task.name})"
          end
        end
      end

      # Log the final mappings
      debug_log "Final project mappings:"
      @project_mapping.each do |source_id, target_project|
        debug_log "  Source project #{source_id} -> Target project #{target_project.id} (#{target_project.name})"
      end

      debug_log "Final task mappings:"
      @task_mapping.each do |source_id, target_task|
        debug_log "  Source task #{source_id} -> Target task #{target_task.id} (#{target_task.name})"
      end
    end

    def match_project(target_project)
      # Create array of search objects manually since we can't call map on EntityCollection
      searchable_projects = []

      # Manually iterate since we can't rely on Enumerable methods
      @source_projects.each do |project|
        debug_log "Checking source project: #{project.inspect}" if @debug
        searchable_projects << { original: project, name: project.name }
      end

      matcher = FuzzyMatch.new(searchable_projects, read: :name)
      match = matcher.find(target_project.name, threshold: @project_match_threshold)
      match[:original] if match
    end

    def match_task(target_task, source_project)
      # Get tasks from the source project
      tasks = source_project.tasks

      # Create array of search objects manually since we can't rely on Enumerable methods

      # Manually iterate through tasks
      searchable_tasks = tasks.map do |task|
        { original: task, name: task.name }
      end

      # Only proceed if we have tasks to match against
      return nil if searchable_tasks.empty?

      matcher = FuzzyMatch.new(searchable_tasks, read: :name)
      match = matcher.find(target_task.name, threshold: @task_match_threshold)
      match[:original] if match
    end
  end
end
