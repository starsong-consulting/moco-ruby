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
    def tasks
      # If tasks are already embedded in the attributes (e.g., from projects.assigned),
      # return them directly instead of making a new API call
      embedded_tasks = attributes[:tasks]
      if embedded_tasks.is_a?(Array) && embedded_tasks.all? { |t| t.is_a?(MOCO::Task) }
        return embedded_tasks
      end

      # Otherwise, create a proxy for fetching tasks via API
      # Don't cache the proxy - create a fresh one each time
      # This ensures we get fresh data when tasks are created/updated/deleted
      MOCO::NestedCollectionProxy.new(client, self, :tasks, "Task")
    end

    def to_s
      "Project #{identifier} \"#{name}\" (#{id})"
    end

    def active?
      status == "active"
    end
  end
end
