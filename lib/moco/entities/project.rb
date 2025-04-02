# frozen_string_literal: true

module MOCO
  # Represents a MOCO project
  # Provides methods for project-specific operations and associations
  class Project < BaseEntity
    # Instance methods for project-specific operations
    def archive
      client.put("projects/#{id}/archive")
      self
    end

    def unarchive
      client.put("projects/#{id}/unarchive")
      self
    end

    def report
      client.get("projects/#{id}/report")
    end

    def share
      client.put("projects/#{id}/share")
      self
    end

    def disable_share
      client.put("projects/#{id}/disable_share")
      self
    end

    def assign_to_group(group_id)
      client.put("projects/#{id}/assign_project_group", { project_group_id: group_id })
      self
    end

    def unassign_from_group
      client.put("projects/#{id}/unassign_project_group")
      self
    end

    # Associations
    def tasks
      return client.tasks.where(project_id: id) if client.respond_to?(:tasks)

      # If tasks are included in the attributes, convert them to Task objects
      if attributes[:tasks].is_a?(Array)
        attributes[:tasks].map do |task_data|
          MOCO::Task.new(client, task_data)
        end
      else
        []
      end
    end

    def activities
      client.activities.where(project_id: id)
    end

    def expenses
      client.expenses.where(project_id: id)
    end

    def customer
      association(:customer, "Company") || association(:company, "Company")
    end

    def project_group
      association(:project_group)
    end

    def to_s
      "#{id} - #{name} (#{customer&.name})"
    end
  end
end
