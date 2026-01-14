# frozen_string_literal: true

module MOCO
  # Represents MOCO internal hourly rates (Interne Stundensätze)
  # Internal cost rates per user for profitability calculations
  #
  # == Read-only structure (per user):
  #   id, full_name, rates (Array by year)
  #
  # == Rate format:
  #   { year: 2024, rate: 120.0 }
  #
  # == Filtering:
  #   moco.internal_hourly_rates.where(years: "2024")
  #   moco.internal_hourly_rates.where(years: "2023,2024")
  #   moco.internal_hourly_rates.where(unit_id: 123)
  #   moco.internal_hourly_rates.where(include_archived: true)
  #
  # == Updating rates:
  #   Use PATCH with year and rates array:
  #   { year: 2024, rates: [{ user_id: 123, rate: 140.0 }] }
  #
  class InternalHourlyRate < BaseEntity
    def self.entity_path
      "account/internal_hourly_rates"
    end

    def to_s
      "#{name} - #{rate}"
    end
  end
end
