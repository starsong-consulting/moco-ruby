# frozen_string_literal: true

module MOCO
  # Represents a MOCO expense template (Zusatzleistungs-Katalog)
  # Pre-defined templates for project additional services
  #
  # == Required attributes for create:
  #   title      - String, template name (e.g., "Hosting L")
  #   unit       - String, unit type (e.g., "month", "hours", "pieces")
  #   unit_price - Float, price per unit
  #   currency   - String, currency code (e.g., "EUR")
  #
  # == Optional attributes:
  #   description - String, detailed description
  #   unit_cost   - Float, internal cost per unit
  #
  # == Read-only attributes:
  #   id, revenue_category (Hash), created_at, updated_at
  #
  # == Example:
  #   moco.expense_templates.create(
  #     title: "Monthly Hosting",
  #     description: "Web hosting with monitoring and backup",
  #     unit: "month",
  #     unit_price: 50.0,
  #     unit_cost: 30.0,
  #     currency: "EUR"
  #   )
  #
  class ExpenseTemplate < BaseEntity
    def self.entity_path
      "account/expense_templates"
    end

    def to_s
      name.to_s
    end
  end
end
