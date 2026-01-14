# frozen_string_literal: true

module MOCO
  # Represents a MOCO purchase VAT code (read-only)
  class VatCodePurchase < BaseEntity
    def self.entity_path
      "vat_code_purchases"
    end

    def to_s
      "#{code} - #{name}"
    end
  end
end
