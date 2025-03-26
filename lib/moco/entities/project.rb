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
      client.tasks.where(project_id: id)
    end

    def activities
      client.activities.where(project_id: id)
    end

    def expenses
      client.expenses.where(project_id: id)
    end

    def customer
      @customer ||= client.companies.find(customer_id) if customer_id
    end

    def project_group
      @project_group ||= client.project_groups.find(project_group_id) if project_group_id
    end

    def to_s
      "#{id} - #{name} (#{customer&.name})"
    end
  end
end
