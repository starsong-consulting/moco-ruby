# frozen_string_literal: true

module MOCO
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
        reason: reason,
        activity_ids: activity_ids,
        company_id: company_id
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
      @project ||= client.projects.find(project_id) if project_id
    end
    
    def task
      @task ||= client.tasks.find(task_id) if task_id
    end
    
    def user
      @user ||= client.users.find(user_id) if user_id
    end
    
    def customer
      @customer ||= client.companies.find(customer_id) if customer_id
    end
    
    def to_s
      "#{date} - #{hours}h - #{project&.name} - #{task&.name} - #{description}"
    end
  end
end
