# frozen_string_literal: true

module MOCO
  # Represents a MOCO internal hourly rate (account-level)
  class InternalHourlyRate < BaseEntity
    def self.entity_path
      "account/internal_hourly_rates"
    end

    def to_s
      "#{name} - #{rate}"
    end
  end
end
