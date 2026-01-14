# frozen_string_literal: true

module MOCO
  # Represents a MOCO invoice reminder (nested under invoice)
  class InvoiceReminder < BaseEntity
    # Associations
    def invoice
      association(:invoice)
    end

    def to_s
      "Reminder ##{id} (#{date})"
    end
  end
end
