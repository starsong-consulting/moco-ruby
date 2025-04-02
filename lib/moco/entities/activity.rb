# frozen_string_literal: true

module MOCO
  # Represents a MOCO activity (time entry)
  # Provides methods for activity-specific operations and associations
  class Activity < BaseEntity
    # Instance methods for activity-specific operations
    def start_timer
      client.patch("activities/#{id}/start_timer")
      self
    end

    def stop_timer
      client.patch("activities/#{id}/stop_timer")
      self
    end

    # Class methods for bulk operations
    def self.disregard(client, reason:, activity_ids:, company_id:, project_id: nil)
      payload = {
        reason:,
        activity_ids:,
        company_id:
      }
      payload[:project_id] = project_id if project_id
      client.post("activities/disregard", payload)
    end

    def self.bulk_create(client, activities)
      api_entities = activities.map do |activity|
        activity.to_h.except(:id, :project, :user, :customer).tap do |h|
          h[:project_id] = activity.project.id if activity.project
          h[:task_id] = activity.task.id if activity.task
        end
      end
      client.post("activities/bulk", { activities: api_entities })
    end

    # Associations
    def project
      association(:project)
    end

    def task
      association(:task)
    end

    def user
      association(:user)
    end

    def customer
      association(:customer, "Company")
    end

    def to_s
      "#{date} - #{hours}h - #{project&.name} - #{task&.name} - #{description}"
    end
  end
end
