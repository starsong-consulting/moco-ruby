# frozen_string_literal: true

module MOCO
  class Project < BaseEntity
    def customer
      # Use the association method to fetch the customer
      association(:customer, "Company")
    end

    # Fetches activities associated with this project.
    def activities
      # Use the has_many method to fetch activities
      has_many(:activities)
    end

    # Fetches tasks associated with this project.
    def tasks
      # Check if tasks are already loaded in attributes
      if attributes[:tasks].is_a?(Array) && attributes[:tasks].all? { |t| t.is_a?(MOCO::Task) }
        # If tasks are already loaded, create a NestedCollectionProxy with the loaded tasks
        @_tasks_proxy ||= begin
          require_relative "../nested_collection_proxy"
          proxy = MOCO::NestedCollectionProxy.new(client, self, :tasks, "Task")
          # We need to manually set the loaded records since we already have them
          proxy.instance_variable_set(:@records, attributes[:tasks])
          proxy.instance_variable_set(:@loaded, true)
          proxy
        end
      else
        # Otherwise, use has_many with nested=true
        has_many(:tasks, nil, nil, true)
      end
    end

    def active?
      status == "active"
    end
  end
end
