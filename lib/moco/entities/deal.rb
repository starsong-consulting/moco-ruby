# frozen_string_literal: true

module MOCO
  # Represents a MOCO deal/lead
  #
  # == Required attributes for create:
  #   name             - String, deal name (e.g., "Website Relaunch")
  #   currency         - String, 3-letter code (e.g., "EUR", "USD")
  #   money            - Float/Integer, deal value (e.g., 25000)
  #   reminder_date    - String, "YYYY-MM-DD" format for follow-up
  #   user_id          - Integer, responsible user ID
  #   deal_category_id - Integer, deal category/stage ID
  #
  # == Optional attributes:
  #   company_id   - Integer, associated company ID
  #   person_id    - Integer, associated contact ID
  #   info         - String, additional information
  #   status       - String, one of: "potential", "pending", "won", "lost", "dropped"
  #                  (default: "pending")
  #   closed_on    - String, "YYYY-MM-DD" when deal was closed
  #   service_period_from - String, "YYYY-MM-DD" (must be 1st of month)
  #   service_period_to   - String, "YYYY-MM-DD" (must be last of month)
  #   tags         - Array of Strings, e.g., ["Important", "Q1"]
  #   custom_properties - Hash, e.g., {"Source": "Website"}
  #
  # == Read-only attributes (returned by API):
  #   id, user (Hash), company (Hash), person (Hash), category (Hash),
  #   created_at, updated_at
  #
  # == Example:
  #   moco.deals.create(
  #     name: "New Website Project",
  #     currency: "EUR",
  #     money: 50000,
  #     reminder_date: "2024-02-01",
  #     user_id: 123,
  #     deal_category_id: 456,
  #     company_id: 789,
  #     status: "pending"
  #   )
  #
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
