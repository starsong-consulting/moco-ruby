# frozen_string_literal: true

module MOCO
  # Represents a MOCO invoice
  #
  # == Required attributes for create:
  #   customer_id       - Integer, customer company ID
  #   recipient_address - String, full address (use \n for line breaks)
  #   date              - String, "YYYY-MM-DD" invoice date
  #   due_date          - String, "YYYY-MM-DD" payment due date
  #   title             - String, invoice title (e.g., "Invoice")
  #   tax               - Float, tax rate percentage (e.g., 19.0)
  #   currency          - String, 3-letter code (e.g., "EUR")
  #   items             - Array of Hashes, invoice line items (see below)
  #
  # == Item types (for items array):
  #   { type: "title", title: "Section Title" }
  #   { type: "description", description: "Some description text" }
  #   { type: "item", title: "Service", quantity: 10, unit: "h", unit_price: 150.0 }
  #   { type: "item", title: "Fixed Fee", net_total: 500.0 }  # lump sum
  #   { type: "subtotal" }
  #   { type: "separator" }
  #   { type: "page-break" }
  #
  # == Optional attributes:
  #   project_id        - Integer, associated project ID
  #   status            - String, "created" or "draft" (default: "created")
  #   service_period_from - String, "YYYY-MM-DD"
  #   service_period_to   - String, "YYYY-MM-DD"
  #   change_address    - String, "invoice", "project", or "customer"
  #   salutation        - String, greeting text (HTML allowed)
  #   footer            - String, footer text (HTML allowed)
  #   discount          - Float, discount percentage
  #   cash_discount     - Float, early payment discount percentage
  #   cash_discount_days - Integer, days for early payment discount
  #   tags              - Array of Strings
  #   custom_properties - Hash
  #
  # == Read-only attributes:
  #   id, identifier, status, net_total, gross_total, payments, reminders,
  #   created_at, updated_at
  #
  # == Example:
  #   moco.invoices.create(
  #     customer_id: 123456,
  #     recipient_address: "Acme Corp\n123 Main St\n12345 City",
  #     date: "2024-01-15",
  #     due_date: "2024-02-15",
  #     title: "Invoice",
  #     tax: 19.0,
  #     currency: "EUR",
  #     items: [
  #       { type: "title", title: "Services January 2024" },
  #       { type: "item", title: "Development", quantity: 40, unit: "h", unit_price: 150.0 },
  #       { type: "item", title: "Project Management", quantity: 8, unit: "h", unit_price: 120.0 }
  #     ]
  #   )
  #
  class Invoice < BaseEntity
    # Instance methods for invoice-specific operations
    def update_status(status)
      client.put("invoices/#{id}/update_status", { status: })
      self
    end

    def pdf
      client.get("invoices/#{id}.pdf")
    end

    def timesheet
      client.get("invoices/#{id}/timesheet")
    end

    def timesheet_pdf
      client.get("invoices/#{id}/timesheet.pdf")
    end

    def expenses
      client.get("invoices/#{id}/expenses")
    end

    def send_email(recipient:, subject:, text:, **options)
      payload = {
        recipient:,
        subject:,
        text:
      }.merge(options)

      client.post("invoices/#{id}/send_email", payload)
      self
    end

    # Get attachments for this invoice
    def attachments
      client.get("invoices/#{id}/attachments")
    end

    # Add an attachment to the invoice
    def add_attachment(file_data)
      client.post("invoices/#{id}/attachments", file_data)
      self
    end

    # Delete an attachment from the invoice
    def delete_attachment(attachment_id)
      client.delete("invoices/#{id}/attachments/#{attachment_id}")
      self
    end

    # Fetches payments for this invoice
    def payments
      MOCO::NestedCollectionProxy.new(client, self, :payments, "InvoicePayment")
    end

    # Fetches reminders for this invoice
    def reminders
      MOCO::NestedCollectionProxy.new(client, self, :reminders, "InvoiceReminder")
    end

    # Associations
    def company
      association(:customer, "Company")
    end

    def project
      association(:project)
    end

    def to_s
      "#{identifier} - #{title} (#{date})"
    end
  end
end
