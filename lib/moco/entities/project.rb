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
      # Use the has_many method to fetch tasks
      has_many(:tasks)
    end

    def active?
      status == "active"
    end
  end
end
