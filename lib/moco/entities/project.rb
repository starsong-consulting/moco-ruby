# frozen_string_literal: true

module MOCO
  class Project < BaseEntity
    def customers
      # NOTE: customer_id is not directly available in Project attributes,
      # need to use the customer association.
      customer_obj = association(:customer)
      customer_obj ? client.companies.find(customer_obj.id) : nil
    end

    # Fetches activities associated with this project.
    def activities
      client.activities.where(project_id: id)
    end

    def active?
      status == "active"
    end
  end
end
