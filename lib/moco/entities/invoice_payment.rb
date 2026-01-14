# frozen_string_literal: true

module MOCO
  # Represents a MOCO invoice payment record
  # (Rechnungen / Zahlungen) for tracking received payments
  #
  # == Required attributes for create:
  #   date       - String, "YYYY-MM-DD" payment date
  #   paid_total - Float, amount received
  #
  # == Optional attributes:
  #   invoice_id     - Integer, invoice being paid (required unless description set)
  #   currency       - String, payment currency (e.g., "EUR")
  #   partially_paid - Boolean, mark as partial payment
  #   description    - String, payment description (required if no invoice_id)
  #
  # == Read-only attributes:
  #   id, invoice (Hash), paid_total_in_account_currency,
  #   created_at, updated_at
  #
  # == Example:
  #   moco.invoice_payments.create(
  #     date: "2024-01-20",
  #     invoice_id: 456,
  #     paid_total: 5000.0,
  #     currency: "EUR"
  #   )
  #
  # == Bulk create:
  #   moco.post("invoices/payments/bulk", {
  #     bulk_data: [
  #       { date: "2024-01-20", invoice_id: 123, paid_total: 1000 },
  #       { date: "2024-01-21", invoice_id: 456, paid_total: 2000 }
  #     ]
  #   })
  #
  # == Filtering:
  #   moco.invoice_payments.where(invoice_id: 123)
  #   moco.invoice_payments.where(date_from: "2024-01-01", date_to: "2024-01-31")
  #
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
