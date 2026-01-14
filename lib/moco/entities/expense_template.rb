# frozen_string_literal: true

module MOCO
  # Represents a MOCO expense template (account-level)
  class ExpenseTemplate < BaseEntity
    def self.entity_path
      "account/expense_templates"
    end

    def to_s
      name.to_s
    end
  end
end
