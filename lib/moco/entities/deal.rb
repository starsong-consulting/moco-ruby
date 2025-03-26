# frozen_string_literal: true

module MOCO
  # Represents a MOCO deal
  # Provides methods for deal-specific associations
  class Deal < BaseEntity
    # Associations
    def company
      @company ||= client.companies.find(company_id) if company_id
    end

    def user
      @user ||= client.users.find(user_id) if user_id
    end

    def category
      @category ||= client.deal_categories.find(category_id) if category_id
    end

    def to_s
      "#{name} (#{company&.name})"
    end
  end
end
