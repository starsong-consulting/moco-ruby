# frozen_string_literal: true

module MOCO
  # Represents a MOCO purchase VAT code (Steuerschlüssel Einkauf)
  # Read-only VAT rates for purchases/receipts
  #
  # == Read-only attributes:
  #   id, code, tax, reverse_charge, intra_eu, active
  #
  # == Filtering:
  #   moco.vat_code_purchases.where(active: true)
  #   moco.vat_code_purchases.where(reverse_charge: true)
  #   moco.vat_code_purchases.where(intra_eu: true)
  #   moco.vat_code_purchases.where(ids: "123,456")
  #
  # == Note:
  #   VAT codes are configured in MOCO's admin interface.
  #   Use vat_code_id when creating purchases/receipts.
  #
  class VatCodePurchase < BaseEntity
    def self.entity_path
      "vat_code_purchases"
    end

    def to_s
      "#{code} - #{name}"
    end
  end
end
