# frozen_string_literal: true

module MOCO
  # Represents a MOCO invoice payment (nested under invoice)
  class InvoicePayment < BaseEntity
    # Associations
    def invoice
      association(:invoice)
    end

    def to_s
      "Payment ##{id} (#{date})"
    end
  end
end
