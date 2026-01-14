# frozen_string_literal: true

module MOCO
  # Represents a MOCO purchase/expense (Ausgaben)
  #
  # == Required attributes for create:
  #   date           - String, "YYYY-MM-DD" format
  #   currency       - String, valid currency code (e.g., "EUR", "CHF", "USD")
  #   payment_method - String, one of:
  #                    "bank_transfer", "direct_debit", "credit_card",
  #                    "paypal", "cash", "bank_transfer_swiss_qr_esr"
  #   items          - Array of item hashes (at least one required):
  #                    { title: "Item", total: 100.0, tax: 7.7, tax_included: true }
  #
  # == Optional attributes:
  #   title              - String, purchase title (auto-generated from items if omitted)
  #   due_date           - String, "YYYY-MM-DD" payment due date
  #   service_period_from - String, "YYYY-MM-DD" service period start
  #   service_period_to   - String, "YYYY-MM-DD" service period end
  #   status             - String, "pending" (Inbox) or "archived" (Archive)
  #   company_id         - Integer, supplier company ID
  #   user_id            - Integer, responsible user ID
  #   receipt_identifier - String, supplier's invoice number
  #   info               - String, free text notes
  #   iban               - String, bank account for payment
  #   reference          - String, payment reference
  #   custom_property_values - Hash, custom field values
  #   tags               - Array of Strings, labels
  #   file               - Hash, { filename: "doc.pdf", base64: "..." }
  #
  # == Item attributes:
  #   title        - String, item description
  #   total        - Float, item total amount
  #   tax          - Float, tax percentage (e.g., 7.7)
  #   tax_included - Boolean, whether total includes tax
  #   category_id  - Integer, purchase category ID
  #
  # == Read-only attributes:
  #   id, identifier, net_total, gross_total, payments (Array),
  #   approval_status, file_url, company (Hash), user (Hash),
  #   created_at, updated_at
  #
  # == Example:
  #   moco.purchases.create(
  #     date: "2024-01-15",
  #     currency: "EUR",
  #     payment_method: "bank_transfer",
  #     company_id: 456,
  #     items: [
  #       { title: "Office supplies", total: 119.0, tax: 19.0, tax_included: true }
  #     ],
  #     tags: ["Office"]
  #   )
  #
  class Purchase < BaseEntity
    # Assign purchase to a project expense
    def assign_to_project(project_id:, project_expense_id: nil)
      payload = { project_id: }
      payload[:project_expense_id] = project_expense_id if project_expense_id

      client.post("purchases/#{id}/assign_to_project", payload)
      reload
    end

    # Update purchase status (pending/archived)
    def update_status(status)
      client.patch("purchases/#{id}/update_status", { status: })
      reload
    end

    # Store/upload a document for this purchase
    def store_document(file_data)
      client.patch("purchases/#{id}/store_document", file_data)
      self
    end

    # Associations
    def company
      association(:company)
    end

    def user
      association(:user)
    end

    def to_s
      "#{title} (#{date})"
    end
  end
end
