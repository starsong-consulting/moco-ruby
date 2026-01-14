# frozen_string_literal: true

module MOCO
  # Represents a MOCO invoice bookkeeping export (Buchhaltungsexporte)
  # Exports invoice data for accounting systems
  #
  # == Read-only attributes:
  #   id, from, to, file_url, user (Hash),
  #   created_at, updated_at
  #
  # == Filtering:
  #   moco.invoice_bookkeeping_exports.all
  #   moco.invoice_bookkeeping_exports.where(from: "2024-01-01", to: "2024-01-31")
  #
  # == Note:
  #   Bookkeeping exports are generated via MOCO's finance interface.
  #   This endpoint provides read-only access to export records.
  #
  class InvoiceBookkeepingExport < BaseEntity
    # Custom path since it's nested under invoices
    def self.entity_path
      "invoices/bookkeeping_exports"
    end

    def user
      association(:user, "User")
    end

    def to_s
      "InvoiceBookkeepingExport #{id} (#{from} - #{to})"
    end
  end
end
