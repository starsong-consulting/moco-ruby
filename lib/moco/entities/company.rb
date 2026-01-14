# frozen_string_literal: true

module MOCO
  # Represents a MOCO company (customer, supplier, or organization)
  #
  # == Required attributes for create:
  #   name     - String, company name (e.g., "Acme Corp")
  #   type     - String, one of: "customer", "supplier", "organization"
  #   currency - String, 3-letter code (e.g., "EUR") - required for customers only
  #
  # == Optional attributes (all types):
  #   identifier   - String, company identifier (e.g., "K-123") - required if manual numbering
  #   country_code - String, ISO Alpha-2 code in uppercase (e.g., "DE", "CH", "US")
  #   vat_identifier - String, EU VAT ID (e.g., "DE123456789")
  #   website      - String, company website URL
  #   phone        - String, phone number
  #   fax          - String, fax number
  #   email        - String, main email address
  #   billing_email_cc - String, CC for billing emails
  #   billing_notes - String, notes for billing
  #   address      - String, full address (use \n for line breaks)
  #   info         - String, additional information
  #   tags         - Array of Strings, e.g., ["Network", "Print"]
  #   custom_properties - Hash, e.g., {"UID": "123-ABC"}
  #   user_id      - Integer, responsible person (user ID)
  #   footer       - String, HTML footer for invoices
  #   alternative_correspondence_language - Boolean, use alternative language
  #
  # == Customer-specific attributes:
  #   customer_tax - Float, tax rate for customer (e.g., 19.0)
  #   default_invoice_due_days - Integer, payment terms (e.g., 30)
  #   debit_number - Integer, for bookkeeping (e.g., 10000)
  #
  # == Supplier-specific attributes:
  #   bank_owner   - String, bank account holder name
  #   iban         - String, bank account IBAN
  #   bank_bic     - String, bank BIC/SWIFT code
  #   supplier_tax - Float, tax rate for supplier
  #   credit_number - Integer, for bookkeeping (e.g., 70000)
  #
  # == Read-only attributes (returned by API):
  #   id, intern, projects (Array), user (Hash), created_at, updated_at
  #
  # == Example:
  #   # Create a customer
  #   moco.companies.create(
  #     name: "Acme Corp",
  #     type: "customer",
  #     currency: "EUR",
  #     country_code: "DE",
  #     email: "info@acme.com"
  #   )
  #
  #   # Create a supplier
  #   moco.companies.create(
  #     name: "Office Supplies Inc",
  #     type: "supplier",
  #     iban: "DE89370400440532013000"
  #   )
  #
  class Company < BaseEntity
    # Associations
    def projects
      has_many(:projects)
    end

    def invoices
      has_many(:invoices)
    end

    def deals
      has_many(:deals)
    end

    def contacts
      has_many(:contacts)
    end

    def to_s
      name
    end
  end
end
