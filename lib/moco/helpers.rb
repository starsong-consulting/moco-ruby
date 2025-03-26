# frozen_string_literal: true

module MOCO
  # Utility class with helper methods for the MOCO API
  class Helpers
    def self.decimal_hours_to_civil(decimal_hours)
      hours = decimal_hours.floor
      fractional_hours = decimal_hours - hours
      minutes = (fractional_hours * 60).round
      "#{hours}:#{format("%02d", minutes)}"
    end
  end
end
