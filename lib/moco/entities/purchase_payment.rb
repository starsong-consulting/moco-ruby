# frozen_string_literal: true

module MOCO
  # Purchase payments (Ausgaben / Zahlungen)
  # Full CRUD endpoint: /purchases/payments
  class PurchasePayment < BaseEntity
    # Custom path since it's nested under purchases
    def self.entity_path
      "purchases/payments"
    end

    def purchase
      association(:purchase, "Purchase")
    end

    def to_s
      "PurchasePayment #{id}: #{total} on #{date}"
    end
  end
end
