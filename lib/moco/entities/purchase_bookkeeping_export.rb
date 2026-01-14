# frozen_string_literal: true

module MOCO
  # Bookkeeping exports for purchases (Ausgaben / Buchhaltungsexporte)
  # Endpoint: /purchases/bookkeeping_exports
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
