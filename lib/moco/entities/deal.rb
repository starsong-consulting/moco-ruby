# frozen_string_literal: true

module MOCO
  # Represents a MOCO deal
  # Provides methods for deal-specific associations
  class Deal < BaseEntity
    # Associations
    def company
      association(:company) || association(:customer, "Company")
    end

    def user
      association(:user)
    end

    def category
      association(:category, "DealCategory")
    end

    def to_s
      "#{name} (#{company&.name})"
    end
  end
end
