# frozen_string_literal: true

module MOCO
  # Represents a MOCO purchase category (Ausgaben – Kategorien)
  # Read-only expense categories for organizing purchases
  #
  # == Read-only attributes:
  #   id, name, credit_account, active, created_at, updated_at
  #
  # == Example:
  #   # List all categories
  #   moco.purchase_categories.all
  #
  #   # Use category when creating purchase
  #   moco.purchases.create(
  #     # ... other fields ...
  #     items: [{
  #       title: "Travel",
  #       total: 250.0,
  #       tax: 7.7,
  #       category_id: 123  # from purchase_categories
  #     }]
  #   )
  #
  # == Note:
  #   Purchase categories are configured in MOCO's admin interface.
  #   This endpoint provides read-only access.
  #
  class PurchaseCategory < BaseEntity
    def self.entity_path
      "purchases/categories"
    end

    def to_s
      name.to_s
    end
  end
end
