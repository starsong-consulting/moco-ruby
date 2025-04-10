# frozen_string_literal: true

module MOCO
  # Represents a MOCO company (customer)
  # Provides methods for company-specific associations
  class Company < BaseEntity
    # Associations
    def projects
      has_many(:projects)
    end

    def invoices
      has_many(:invoices)
    end

    def deals
      has_many(:deals)
    end

    def contacts
      has_many(:contacts)
    end

    def to_s
      name
    end
  end
end
