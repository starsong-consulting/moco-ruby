# frozen_string_literal: true

module MOCO
  # Represents a MOCO custom property/field definition (Eigene Felder)
  #
  # == Required attributes for create:
  #   name   - String, field name (e.g., "Purchase Order Number")
  #   kind   - String, field type:
  #            "String", "Textarea", "Link", "Boolean",
  #            "Select", "MultiSelect", "Date"
  #   entity - String, entity type this field applies to:
  #            "Project", "Customer", "Deal", etc.
  #
  # == Optional attributes:
  #   placeholder          - String, placeholder text for input
  #   placeholder_alt      - String, placeholder in alternative language
  #   print_on_invoice     - Boolean, show on invoices
  #   print_on_offer       - Boolean, show on offers
  #   print_on_timesheet   - Boolean, show on timesheets
  #   notification_enabled - Boolean, send notification for Date fields
  #   api_only             - Boolean, hide from UI (API access only)
  #   defaults             - Array, options for Select/MultiSelect types
  #
  # == Read-only attributes:
  #   id, name_alt, created_at, updated_at
  #
  # == Example:
  #   # Create a dropdown field
  #   moco.custom_properties.create(
  #     name: "Project Type",
  #     kind: "Select",
  #     entity: "Project",
  #     defaults: ["Website", "Mobile App", "API Integration"],
  #     print_on_invoice: true
  #   )
  #
  # == Note:
  #   `kind` and `entity` cannot be changed after creation.
  #
  class CustomProperty < BaseEntity
    def self.entity_path
      "account/custom_properties"
    end

    def to_s
      name.to_s
    end
  end
end
