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

      target_activity_filters = @filters.fetch(:target, {})
      target_activities_r = @target.activities.where(target_activity_filters).all

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
        unless @dry_run
          debug_log "    Executing API create."
          # Pass attributes hash to create
          created_activity = @target.activities.create(expected_target_activity.attributes)
          results << created_activity
          # Pass the actual created activity object to the callback
          callbacks&.call(:created, source_activity, created_activity, results.last)
        end
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
      mapped_task = @task_mapping[source_activity.task.id]
      mapped_project = @project_mapping[source_activity.project.id]
      
      # Set the task_id and project_id attributes instead of the full objects
      attrs[:task_id] = mapped_task.id if mapped_task
      attrs[:project_id] = mapped_project.id if mapped_project
      
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
          score = score_activity_match(get_expected_target_activity(source_activity), target_activity)
          matches << { activity: [source_activity, target_activity], score: }
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

    # rubocop:disable Metrics/AbcSize
    def score_activity_match(a, b)
      return 0 if a.project != b.project

      score = 0
      # (mapped) task is the same as the source task
      score += 20 if a.task == b.task
      # description fuzzy match score (0.0 .. 1.0)
      _, description_match_score = FuzzyMatch.new([a.description]).find_with_score(b.description)
      score += (description_match_score * 40.0).to_i if description_match_score
      # differences in time tracked are weighted by sqrt of diff clamped to 7h
      # i.e. smaller differences are worth higher scores; 1.75h diff = 0.5 score * 40
      score += (clamped_factored_diff_score(a.hours, b.hours) * 40.0).to_i

      score
    end
    # rubocop:enable Metrics/AbcSize

    def fetch_assigned_projects
      # Use .projects.assigned for the source, standard .projects for the target
      source_filters = @filters.fetch(:source, {}).merge(active: "true")
      # Get the proxy, then fetch all results into the instance variable
      @source_projects = @source.projects.assigned.where(source_filters).all

      target_filters = @filters.fetch(:target, {}).merge(active: "true")
      # Get the proxy, then fetch all results into the instance variable
      @target_projects = @target.projects.where(target_filters).all

      # NOTE: The @source_projects and @target_projects are now Arrays of entities,
      #       not CollectionProxy or EntityCollection objects.
    end

    def build_initial_mappings
      @target_projects.each do |target_project|
        source_project = match_project(target_project)
        next unless source_project

        @project_mapping[source_project.id] = target_project
        target_project.tasks.each do |target_task|
          source_task = match_task(target_task, source_project)
          @task_mapping[source_task.id] = target_task if source_task
        end
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
