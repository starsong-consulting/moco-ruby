# frozen_string_literal: true

module MOCO
  # Represents a MOCO purchase bookkeeping export
  # (Ausgaben / Buchhaltungsexporte)
  # Exports purchase data for accounting systems
  #
  # == Read-only attributes:
  #   id, from, to, file_url, user (Hash),
  #   created_at, updated_at
  #
  # == Filtering:
  #   moco.purchase_bookkeeping_exports.all
  #   moco.purchase_bookkeeping_exports.where(from: "2024-01-01", to: "2024-01-31")
  #
  # == Note:
  #   Bookkeeping exports are generated via MOCO's finance interface.
  #   This endpoint provides read-only access to export records.
  #
  class PurchaseBookkeepingExport < BaseEntity
    # Custom path since it's nested under purchases
    def self.entity_path
      "purchases/bookkeeping_exports"
    end

    def user
      association(:user, "User")
    end

    def to_s
      "PurchaseBookkeepingExport #{id} (#{from} - #{to})"
    end
  end
end
