# frozen_string_literal: true

module MOCO
  # Represents a MOCO project expense (additional service)
  # Expenses are typically accessed via project: project.expenses.create(...)
  #
  # == Required attributes for create:
  #   date       - String, "YYYY-MM-DD" expense date
  #   title      - String, expense title (e.g., "Hosting XS")
  #   quantity   - Float/Integer, quantity (e.g., 3)
  #   unit       - String, unit label (e.g., "months", "pieces", "hours")
  #   unit_price - Float, price per unit charged to customer
  #   unit_cost  - Float, cost per unit (your cost)
  #
  # == Optional attributes:
  #   description     - String, detailed description
  #   billable        - Boolean, whether expense is billable (default: true)
  #   budget_relevant - Boolean, whether counts toward budget (default: false)
  #   service_period_from - String, "YYYY-MM-DD" service period start
  #   service_period_to   - String, "YYYY-MM-DD" service period end
  #   user_id         - Integer, responsible user ID (default: current user)
  #   custom_properties - Hash, e.g., {"Type": "Infrastructure"}
  #   file            - Hash, { filename: "receipt.pdf", base64: "..." }
  #
  # == Read-only attributes:
  #   id, price, cost, currency, billed, invoice_id, project (Hash),
  #   company (Hash), created_at, updated_at
  #
  # == Example:
  #   project = moco.projects.find(123)
  #   project.expenses.create(
  #     date: "2024-01-15",
  #     title: "Cloud Hosting",
  #     quantity: 1,
  #     unit: "month",
  #     unit_price: 99.0,
  #     unit_cost: 49.0,
  #     billable: true
  #   )
  #
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
