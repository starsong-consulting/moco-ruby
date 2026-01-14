# frozen_string_literal: true

module MOCO
  # Represents a MOCO hourly rate (account-level)
  class HourlyRate < BaseEntity
    def self.entity_path
      "account/hourly_rates"
    end

    def to_s
      "#{name} - #{rate}"
    end
  end
end
