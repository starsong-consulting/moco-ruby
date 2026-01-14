# frozen_string_literal: true

module MOCO
  # Represents a MOCO project recurring expense
  # (Wiederkehrende Zusatzleistungen) for ongoing services like hosting
  #
  # == Required attributes for create:
  #   start_date - String, "YYYY-MM-DD" when recurring starts
  #   period     - String, recurrence interval:
  #                "weekly", "biweekly", "monthly", "quarterly",
  #                "biannual", "annual"
  #   title      - String, expense name (e.g., "Monthly Hosting")
  #   quantity   - Float, number of units per period
  #   unit       - String, unit type (e.g., "Server", "License")
  #   unit_price - Float, price per unit
  #   unit_cost  - Float, internal cost per unit
  #
  # == Optional attributes:
  #   finish_date              - String, "YYYY-MM-DD" when to stop (null = unlimited)
  #   description              - String, detailed description
  #   billable                 - Boolean, whether to invoice (default: true)
  #   budget_relevant          - Boolean, count toward budget (default: false)
  #   service_period_direction - String, "none", "forward", "backward"
  #   custom_properties        - Hash, custom field values
  #
  # == Read-only attributes:
  #   id, price, cost, currency, recur_next_date, project (Hash),
  #   revenue_category (Hash), created_at, updated_at
  #
  # == Example:
  #   moco.post("projects/123/recurring_expenses", {
  #     start_date: "2024-01-01",
  #     period: "monthly",
  #     title: "Web Hosting",
  #     quantity: 1,
  #     unit: "Server",
  #     unit_price: 99.0,
  #     unit_cost: 50.0,
  #     billable: true
  #   })
  #
  # == Note:
  #   start_date and period cannot be modified after creation.
  #
  class RecurringExpense < BaseEntity
    # Associations
    def project
      association(:project)
    end

    def to_s
      "RecurringExpense ##{id} - #{title}"
    end
  end
end
