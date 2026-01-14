# frozen_string_literal: true

module MOCO
  # Represents MOCO hourly rates (Stundensätze)
  # Read-only access to billing rates by task and user
  #
  # == Read-only structure:
  #   defaults_rates - Array of default rates per currency
  #   tasks          - Array of tasks with their rates per currency
  #   users          - Array of users with their rates per currency
  #
  # == Rate format:
  #   { currency: "EUR", hourly_rate: 150.0 }
  #
  # == Filtering:
  #   moco.hourly_rates.where(company_id: 123)  # customer-specific rates
  #   moco.hourly_rates.where(include_archived_users: true)
  #
  # == Note:
  #   Hourly rates are configured in MOCO's admin interface.
  #   This endpoint provides read-only access.
  #   Without company_id, returns global default rates.
  #
  class HourlyRate < BaseEntity
    def self.entity_path
      "account/hourly_rates"
    end

    def to_s
      "#{name} - #{rate}"
    end
  end
end
