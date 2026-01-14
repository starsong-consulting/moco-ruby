# frozen_string_literal: true

module MOCO
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
