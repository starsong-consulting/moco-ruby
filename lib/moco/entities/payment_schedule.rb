# frozen_string_literal: true

module MOCO
  # Represents a MOCO project payment schedule entry (nested under project)
  class PaymentSchedule < BaseEntity
    # Associations
    def project
      association(:project)
    end

    def to_s
      "PaymentSchedule ##{id} (#{date})"
    end
  end
end
