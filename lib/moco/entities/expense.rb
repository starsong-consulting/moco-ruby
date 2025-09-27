# frozen_string_literal: true

module MOCO
  # Represents a MOCO expense
  # Provides methods for expense-specific operations and associations
  class Expense < BaseEntity
    # Override entity_path to use the global expenses endpoint
    # Note: Expenses can also be accessed via projects/{id}/expenses
    def self.entity_path
      "projects/expenses"
    end

    # Class methods for bulk operations
    def self.disregard(client, expense_ids:)
      client.post("projects/expenses/disregard", { expense_ids: })
    end

    def self.bulk_create(client, project_id, expenses)
      client.post("projects/#{project_id}/expenses/bulk", { expenses: })
    end

    # Associations
    def project
      # Use the association method which handles embedded objects
      association(:project, "Project")
    end

    def user
      # Use the association method which handles embedded objects
      association(:user, "User")
    end

    def to_s
      "#{date} - #{title} (#{amount})"
    end
  end
end
