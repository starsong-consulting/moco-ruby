# frozen_string_literal: true

module MOCO
  # Represents a MOCO receipt/expense claim (Spesen)
  #
  # == Required attributes for create:
  #   date     - String, "YYYY-MM-DD" format
  #   title    - String, receipt description (e.g., "Team lunch")
  #   currency - String, valid currency code (e.g., "EUR", "CHF")
  #   items    - Array of item hashes (at least one required):
  #              { vat_code_id: 186, gross_total: 99.90 }
  #
  # == Optional attributes:
  #   project_id - Integer, project to associate with
  #   info       - String, additional notes
  #   billable   - Boolean, whether expense is billable to customer
  #   attachment - Hash, { filename: "receipt.pdf", base64: "..." }
  #
  # == Item attributes:
  #   vat_code_id          - Integer, VAT code ID (required)
  #   gross_total          - Float, total amount including tax (required)
  #   purchase_category_id - Integer, expense category
  #
  # == Read-only attributes:
  #   id, pending, user (Hash), project (Hash), refund_request (Hash),
  #   attachment_url, created_at, updated_at
  #
  # == Example:
  #   moco.receipts.create(
  #     date: "2024-01-15",
  #     title: "Client lunch",
  #     currency: "EUR",
  #     project_id: 123,
  #     billable: true,
  #     items: [
  #       { vat_code_id: 186, gross_total: 85.50 }
  #     ]
  #   )
  #
  # == Filtering:
  #   moco.receipts.where(from: "2024-01-01", to: "2024-01-31")
  #   moco.receipts.where(project_id: 123)
  #   moco.receipts.where(user_id: 456)
  #
  class Receipt < BaseEntity
    # Associations
    def user
      association(:user)
    end

    def to_s
      "#{title} (#{date})"
    end
  end
end
