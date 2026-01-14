# frozen_string_literal: true

module MOCO
  # Represents a MOCO sales VAT code (Steuerschlüssel Verkauf)
  # Read-only VAT rates for invoices/offers
  #
  # == Read-only attributes:
  #   id, code, tax, reverse_charge, intra_eu, active,
  #   print_gross_total, notice_tax_exemption, credit_account
  #
  # == Filtering:
  #   moco.vat_code_sales.where(active: true)
  #   moco.vat_code_sales.where(reverse_charge: true)
  #   moco.vat_code_sales.where(intra_eu: true)  # EU intra-community
  #
  # == Note:
  #   VAT codes are configured in MOCO's admin interface.
  #   Use vat_code_id when creating invoices/offers.
  #
  class VatCodeSale < BaseEntity
    def self.entity_path
      "vat_code_sales"
    end

    def to_s
      "#{code} - #{name}"
    end
  end
end
