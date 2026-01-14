# frozen_string_literal: true

module MOCO
  # Represents a MOCO task template (Standardleistungen)
  # Pre-defined task types for projects
  #
  # == Required attributes for create:
  #   name - String, task name (e.g., "Development", "Design")
  #
  # == Optional attributes:
  #   description         - String, task description
  #   revenue_category_id - Integer, revenue category for invoicing
  #   billable            - Boolean, whether tasks are billable by default
  #   project_default     - Boolean, auto-add to new projects
  #   index               - Integer, display order (e.g., 10, 20, 30)
  #
  # == Read-only attributes:
  #   id, revenue_category (Hash), created_at, updated_at
  #
  # == Example:
  #   moco.task_templates.create(
  #     name: "Backend Development",
  #     description: "Server-side programming",
  #     billable: true,
  #     project_default: true,
  #     index: 10
  #   )
  #
  class TaskTemplate < BaseEntity
    def self.entity_path
      "account/task_templates"
    end

    def to_s
      name.to_s
    end
  end
end
