# frozen_string_literal: true

module MOCO
  # Represents a MOCO purchase payment record (Ausgaben / Zahlungen)
  # For tracking payments made for purchases
  #
  # == Required attributes for create:
  #   date  - String, "YYYY-MM-DD" payment date
  #   total - Float, payment amount
  #
  # == Optional attributes:
  #   purchase_id - Integer, purchase being paid (required unless description set)
  #   description - String, payment description (required if no purchase_id)
  #
  # == Read-only attributes:
  #   id, purchase (Hash), created_at, updated_at
  #
  # == Example:
  #   moco.purchase_payments.create(
  #     date: "2024-01-20",
  #     purchase_id: 456,
  #     total: 1500.0
  #   )
  #
  # == Bulk create:
  #   moco.post("purchases/payments/bulk", {
  #     bulk_data: [
  #       { date: "2024-01-20", purchase_id: 123, total: 500 },
  #       { date: "2024-01-21", description: "Salaries", total: 10000 }
  #     ]
  #   })
  #
  # == Filtering:
  #   moco.purchase_payments.where(purchase_id: 456)
  #   moco.purchase_payments.where(date_from: "2024-01-01", date_to: "2024-01-31")
  #
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
