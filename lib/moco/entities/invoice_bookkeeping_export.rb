# frozen_string_literal: true

module MOCO
  # Bookkeeping exports for invoices (Buchhaltungsexporte)
  # Endpoint: /invoices/bookkeeping_exports
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
