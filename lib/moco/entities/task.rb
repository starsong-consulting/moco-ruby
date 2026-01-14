# frozen_string_literal: true

module MOCO
  # Represents a MOCO task (project service/activity type)
  # Tasks are nested under projects: project.tasks.create(...)
  #
  # == Required attributes for create:
  #   name - String, task name (e.g., "Development", "Design / UX")
  #
  # == Optional attributes:
  #   billable    - Boolean, whether time on this task is billable
  #   active      - Boolean, whether task is active
  #   budget      - Float/Integer, budget in hours or currency
  #   hourly_rate - Float/Integer, rate for this task (used if project billing_variant is "task")
  #   description - String, task description
  #
  # == Read-only attributes (returned by API):
  #   id, created_at, updated_at
  #
  # == Example:
  #   project = moco.projects.find(123)
  #   project.tasks.create(
  #     name: "Development",
  #     billable: true,
  #     hourly_rate: 150,
  #     budget: 100
  #   )
  #
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
