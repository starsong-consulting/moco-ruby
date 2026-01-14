# frozen_string_literal: true

module MOCO
  # Represents a MOCO invoice reminder (Mahnung / Zahlungserinnerung)
  #
  # == Required attributes for create:
  #   invoice_id - Integer, overdue invoice ID
  #
  # == Optional attributes:
  #   title    - String, reminder title (uses default if omitted)
  #   text     - String, reminder message (uses default if omitted)
  #   fee      - Float, late payment fee
  #   date     - String, "YYYY-MM-DD" reminder date
  #   due_date - String, "YYYY-MM-DD" new payment due date
  #
  # == Read-only attributes:
  #   id, status ("created" or "sent"), file_url, invoice (Hash),
  #   created_at, updated_at
  #
  # == Example:
  #   moco.invoice_reminders.create(
  #     invoice_id: 456,
  #     title: "Payment Reminder",
  #     text: "Please remit payment within 14 days.",
  #     fee: 25.0,
  #     date: "2024-02-01",
  #     due_date: "2024-02-15"
  #   )
  #
  # == Send by email:
  #   moco.post("invoice_reminders/123/send_email", {
  #     emails_to: "customer@example.com",
  #     subject: "Payment Reminder",
  #     text: "Please see attached reminder."
  #   })
  #
  # == Filtering:
  #   moco.invoice_reminders.where(invoice_id: 456)
  #   moco.invoice_reminders.where(date_from: "2024-01-01", date_to: "2024-01-31")
  #
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
