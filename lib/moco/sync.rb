# frozen_string_literal: true

require "fuzzy_match"
require_relative "api"

module MOCO
  # Match and map projects and tasks between MOCO instances and sync activities
  class Sync
    attr_reader :project_mapping, :task_mapping, :source_projects, :target_projects
    attr_accessor :project_match_threshold, :task_match_threshold, :dry_run

    def initialize(source_instance_api, target_instance_api, **args)
      @source_api = source_instance_api
      @target_api = target_instance_api
      @project_match_threshold = args.fetch(:project_match_threshold, 0.8)
      @task_match_threshold = args.fetch(:task_match_threshold, 0.45)
      @filters = args.fetch(:filters, {})
      @dry_run = args.fetch(:dry_run, false)

      @project_mapping = {}
      @task_mapping = {}

      fetch_assigned_projects
      build_initial_mappings
    end

    # rubocop:todo Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def sync(&callbacks)
      results = []

      source_activities_r = @source_api.get_activities(@filters.fetch(:source, {}))
      target_activities_r = @target_api.get_activities(@filters.fetch(:target, {}))

      source_activities_grouped = source_activities_r.group_by(&:date).transform_values do |activities|
        activities.group_by(&:project)
      end
      target_activities_grouped = target_activities_r.group_by(&:date).transform_values do |activities|
        activities.group_by(&:project)
      end

      source_activities_grouped.each do |date, activities_by_project|
        activities_by_project.each do |project, source_activities|
          target_activities = target_activities_grouped.fetch(date, {}).fetch(@project_mapping[project.id], [])
          next if source_activities.empty? # || target_activities.empty?

          matches = calculate_matches(source_activities, target_activities)
          matches.sort_by! { |match| -match[:score] }

          used_source_activities = []
          used_target_activities = []

          matches.each do |match|
            source_activity, target_activity = match[:activity]
            score = match[:score]

            next if used_source_activities.include?(source_activity) || used_target_activities.include?(target_activity)

            best_score = score
            best_match = target_activity
            expected_target_activity = get_expected_target_activity(source_activity)

            case best_score
            when 100
              # 100 - perfect match found, nothing needs doing
              callbacks&.call(:equal, source_activity, expected_target_activity)
            when 60...100
              # >=60 <100 - match with some differences
              expected_target_activity.to_h.except(:id, :user, :customer).each do |k, v|
                best_match.send("#{k}=", v)
              end
              callbacks&.call(:update, source_activity, best_match)
              unless @dry_run
                results << @target_api.update_activity(best_match)
                callbacks&.call(:updated, source_activity, best_match, results.last)
              end
            when 0...60
              # <60 - no good match found, create new entry
              callbacks&.call(:create, source_activity, expected_target_activity)
              unless @dry_run
                results << @target_api.create_activity(expected_target_activity)
                callbacks&.call(:created, source_activity, best_match, results.last)
              end
            end

            used_source_activities << source_activity
            used_target_activities << target_activity
          end

          source_activities.each do |source_activity|
            unless used_source_activities.include?(source_activity) 
              expected_target_activity = get_expected_target_activity(source_activity)
              callbacks&.call(:create, source_activity, expected_target_activity)
              unless @dry_run
                results << @target_api.create_activity(expected_target_activity)
                callbacks&.call(:created, source_activity, expected_target_activity, results.last)
              end
            end
          end
        end
      end
      results
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    def get_expected_target_activity(source_activity)
      source_activity.dup.tap do |a|
        a.task = @task_mapping[source_activity.task.id]
        a.project = @project_mapping[source_activity.project.id]
      end
    end

    def calculate_matches(source_activities, target_activities)
      matches = []
      source_activities.each do |source_activity|
        target_activities.each do |target_activity|
          score = score_activity_match(get_expected_target_activity(source_activity), target_activity)
          matches << { activity: [source_activity, target_activity], score: score }
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
      @source_projects = @source_api.get_assigned_projects(**@filters.fetch(:source, {}).merge(active: "true"))
      @target_projects = @target_api.get_assigned_projects(**@filters.fetch(:target, {}).merge(active: "true"))
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
      matcher = FuzzyMatch.new(@source_projects, read: :name)
      matcher.find(target_project.name, threshold: @project_match_threshold)
    end

    def match_task(target_task, source_project)
      matcher = FuzzyMatch.new(source_project.tasks, read: :name)
      matcher.find(target_task.name, threshold: @task_match_threshold)
    end
  end
end
