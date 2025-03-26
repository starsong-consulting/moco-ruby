# frozen_string_literal: true

module MOCO
  # Represents a MOCO task
  # Provides methods for task-specific associations
  class Task < BaseEntity
    # Associations
    def project
      @project ||= client.projects.find(project_id) if project_id
    end

    def activities
      client.activities.where(task_id: id)
    end

    def to_s
      name
    end
  end
end
