# frozen_string_literal: true

module MOCO
  # Represents a MOCO task template (account-level)
  class TaskTemplate < BaseEntity
    def self.entity_path
      "account/task_templates"
    end

    def to_s
      name.to_s
    end
  end
end
