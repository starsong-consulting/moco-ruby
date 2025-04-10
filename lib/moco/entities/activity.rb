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
    # Fetches the associated Project object.
    def project
      # Check if the project attribute is a hash (contains ID) or already an object
      project_data = attributes[:project]
      return @project if defined?(@project) # Return memoized object if already fetched

      @project = if project_data.is_a?(Hash) && project_data[:id]
                   client.projects.find(project_data[:id])
                 elsif project_data.is_a?(MOCO::Project) # If it was already processed into an object
                   project_data
                 else
                   nil # No project associated or data missing
                 end
    end

    # Fetches the associated Task object.
    def task
      task_data = attributes[:task]
      return @task if defined?(@task)

      @task = if task_data.is_a?(Hash) && task_data[:id]
                client.tasks.find(task_data[:id])
              elsif task_data.is_a?(MOCO::Task)
                task_data
              end
    end

    # Fetches the associated User object.
    def user
      user_data = attributes[:user]
      return @user if defined?(@user)

      @user = if user_data.is_a?(Hash) && user_data[:id]
                client.users.find(user_data[:id])
              elsif user_data.is_a?(MOCO::User)
                user_data
              end
    end

    # Fetches the associated Customer (Company) object.
    def customer
      customer_data = attributes[:customer]
      return @customer if defined?(@customer)

      @customer = if customer_data.is_a?(Hash) && customer_data[:id]
                    # Customer association points to the 'companies' collection
                    client.companies.find(customer_data[:id])
                  elsif customer_data.is_a?(MOCO::Company)
                    customer_data
                  end
    end

    def to_s
      "#{date} - #{hours}h - #{project&.name} - #{task&.name} - #{description}"
    end
  end
end
