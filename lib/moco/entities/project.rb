# frozen_string_literal: true

module MOCO
  # Represents a MOCO project
  #
  # == Required attributes for create:
  #   name        - String, project name (e.g., "Website Relaunch")
  #   currency    - String, 3-letter currency code (e.g., "EUR", "USD", "CHF")
  #   start_date  - String, "YYYY-MM-DD" format (required, must be 1st of month if retainer)
  #   finish_date - String, "YYYY-MM-DD" format (required, must be last of month if retainer)
  #   fixed_price - Boolean, true for fixed-price projects
  #   retainer    - Boolean, true for retainer/recurring projects
  #   leader_id   - Integer, user ID of the project leader
  #   customer_id - Integer, company ID of the customer
  #   identifier  - String, project identifier (e.g., "P-123") - only required if manual numbering
  #
  # == Optional attributes:
  #   co_leader_id    - Integer, user ID of co-leader
  #   deal_id         - Integer, associated deal ID
  #   project_group_id - Integer, project group ID
  #   contact_id      - Integer, primary contact ID
  #   secondary_contact_id - Integer, secondary contact ID
  #   billing_contact_id - Integer, billing contact ID
  #   billing_address - String, billing address (multiline with \n)
  #   billing_email_to - String, email for invoices
  #   billing_email_cc - String, CC email for invoices
  #   billing_notes   - String, notes for billing
  #   billing_variant - String, "project", "task", or "user" (default: "project")
  #   setting_include_time_report - Boolean, include time report with invoices
  #   hourly_rate     - Float/Integer, hourly rate (meaning depends on billing_variant)
  #   budget          - Float/Integer, total budget
  #   budget_monthly  - Float/Integer, monthly budget (required if retainer: true)
  #   budget_expenses - Float/Integer, expenses budget
  #   tags            - Array of Strings, e.g., ["Print", "Digital"]
  #   custom_properties - Hash, e.g., {"PO-Number": "123-ABC"}
  #   info            - String, additional info
  #
  # == Read-only attributes (returned by API):
  #   id, active, color, customer (Hash), leader (Hash), co_leader (Hash),
  #   deal (Hash), tasks (Array), contracts (Array), project_group (Hash),
  #   created_at, updated_at
  #
  # == Example:
  #   moco.projects.create(
  #     name: "Website Relaunch",
  #     currency: "EUR",
  #     start_date: "2024-01-01",
  #     finish_date: "2024-12-31",
  #     fixed_price: false,
  #     retainer: false,
  #     leader_id: 123456,
  #     customer_id: 789012,
  #     budget: 50000
  #   )
  #
  class Project < BaseEntity
    def customer
      # Use the association method to fetch the customer
      association(:customer, "Company")
    end

    def leader
      # Use the association method to fetch the leader
      association(:leader, "User")
    end

    def co_leader
      # Use the association method to fetch the co_leader
      association(:co_leader, "User")
    end

    # Fetches activities associated with this project.
    def activities
      # Use the has_many method to fetch activities
      has_many(:activities)
    end

    # Fetches expenses associated with this project.
    def expenses
      # Don't cache the proxy - create a fresh one each time
      # This ensures we get fresh data when expenses are created/updated/deleted
      MOCO::NestedCollectionProxy.new(client, self, :expenses, "Expense")
    end

    # Fetches tasks associated with this project.
    # Always returns a NestedCollectionProxy for consistent interface.
    # Data is fetched lazily when accessed (e.g., .all, .first, .each).
    # Note: Embedded tasks from projects.assigned are available via attributes[:tasks]
    # but may have incomplete fields compared to the dedicated endpoint.
    def tasks
      MOCO::NestedCollectionProxy.new(client, self, :tasks, "Task")
    end

    # Fetches contracts associated with this project.
    def contracts
      MOCO::NestedCollectionProxy.new(client, self, :contracts, "ProjectContract")
    end

    # Fetches payment schedules associated with this project.
    def payment_schedules
      MOCO::NestedCollectionProxy.new(client, self, :payment_schedules, "PaymentSchedule")
    end

    # Fetches recurring expenses associated with this project.
    def recurring_expenses
      MOCO::NestedCollectionProxy.new(client, self, :recurring_expenses, "RecurringExpense")
    end

    # Get the project group
    def project_group
      association(:project_group)
    end

    def to_s
      "Project #{identifier} \"#{name}\" (#{id})"
    end

    def active?
      status == "active"
    end
  end
end
