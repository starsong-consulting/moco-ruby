require 'fuzzy_match'
require_relative './api'

module MOCO
  class Sync
    def initialize(source_instance_api, target_instance_api, config)
      @source_api = source_instance_api
      @target_api = target_instance_api
      @config = config

      @project_mapping = {}
      @task_mapping = {}

      fetch_projects
      build_initial_mappings
    end

    def score_activity_match(a, b)
      return 0 if a.project != b.project

      score = 0
      score += 20 if a.task == b.task
      # score += 40 if (!a.description.empty? && a.description == b.description) || (!a.tag.empty? && a.tag == b.tag)
      _, match_score = FuzzyMatch.new([a.description]).find_with_score(b.description)
      score += (match_score * 40).to_i if match_score
      if a.hours == b.hours
        score += 40
      elsif (a.hours - b.hours).abs <= 0.5
        score += 20
      end

      score
    end

    def sync(filters)
      filters ||= {}
      source_activities = @source_api.get_activities(filters)
      target_activities = @target_api.get_activities(filters)

      source_activities_grouped = source_activities.group_by(&:date).transform_values { |activities| activities.group_by(&:project) }
      target_activities_grouped = target_activities.group_by(&:date).transform_values { |activities| activities.group_by(&:project) }

      source_activities_grouped.each do |date, s_act_on_date|
        s_act_on_date.each do |project, source_project_activities|
          # get corresponding values from target_activities_grouped[date][project]
          # if none found, create all activities
          # otherwise try to match each source activity to each target activity with scoring
          # for each matched activity
          #   if scores are equal, the activities are already the same and can be ignored (log "EQL")
          #   if scores are above the threshold, the activities are likely the same, but have changed, so update the values in target_activity from source_activity
          #   if scores are below the threshold, the activity does not yet exist, so create new target_activity from source_activity
          target_project_activities = target_activities_grouped.fetch(date, {}).fetch(@project_mapping[project.id], []) # Handle missing dates/projects
          puts "syncing #{date} / #{project.name} source #{source_project_activities.size} dest #{target_project_activities.size}"

          source_project_activities.each do |source_activity|
            matches = {}

            expected_target_activity = source_activity.dup.tap do |a|
              a.task = @task_mapping[source_activity.task.id]
              a.project = @project_mapping[source_activity.project.id]
            end

            target_project_activities.each do |target_activity|
              score = score_activity_match(expected_target_activity, target_activity)
              # $stderr.puts "score #{score} comparing\nA: #{source_activity} and\nB: #{target_activity}"

              matches[target_activity] = score
            end
            best_match, best_score = matches.max_by{ |k, v| v }

            if best_score >= 100 # Perfect match
              puts("EQL\n  A: #{source_activity}\n  B: #{best_match}") # Log that nothing needs updating
            elsif best_score >= 60
              diff_keys = expected_target_activity.to_h.except(:id, :user, :customer).map{ |k,v| ov = best_match.send(k.to_sym); [k,v,ov] if v != ov }.reject(&:nil?).to_a if best_match
              puts("UPD\n  A: #{source_activity}\n  B: #{best_match}")
              diff_keys.each do |k, v1, v2|
                puts "  - #{k} #{v1.to_s.inspect} -> #{v2.to_s.inspect}"
                case k
                when :hours, :seconds
                  best_match.send("#{k}=", [v1, v2].max)
                end
              end
              puts "  T: #{best_match}"
              # Update the best_match target activity with data from source_activity
              @target_api.update_activity(best_match)
            else
              puts("NEW  #{source_activity}")
              @target_api.create_activity(expected_target_activity) # Create new
            end
          end
        end
      end
    end

    private

    def fetch_projects
      @source_projects = @source_api.get_assigned_projects(active: "true")
      @target_projects = @target_api.get_assigned_projects(active: "true")
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
      threshold = @config['project_match_threshold'] || 0.8
      matcher = FuzzyMatch.new(@source_projects, read: :name)
      matcher.find(target_project.name, threshold: threshold)
    end

    def match_task(target_task, source_project)
      threshold = @config['project_match_threshold'] || 0.45
      matcher = FuzzyMatch.new(source_project.tasks, read: :name)
      # all_matches = matcher.find_all_with_score(target_task.name)
      matcher.find(target_task.name, threshold: threshold)
    end
  end
end
