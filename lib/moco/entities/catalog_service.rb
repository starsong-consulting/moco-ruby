# frozen_string_literal: true

module MOCO
  # Represents a MOCO catalog service (Leistungskatalog)
  # Pre-defined service templates for offers/invoices
  #
  # == Required attributes for create:
  #   title - String, catalog entry name
  #
  # == Optional attributes:
  #   items - Array of item hashes, service line items
  #
  # == Item types:
  #   { type: "title", title: "Section" }
  #   { type: "description", description: "Details..." }
  #   { type: "item", title: "Service", quantity: 10, unit: "h", unit_price: 150.0, net_total: 1500.0 }
  #   { type: "item", title: "Fixed Fee", net_total: 500.0 }  # lump sum (quantity=0)
  #   { type: "subtotal", part: true }  # subtotal for section
  #   { type: "separator" }
  #   { type: "page-break" }
  #
  # == Item attributes:
  #   title       - String, item title
  #   description - String, item description
  #   quantity    - Float, number of units (0 for lump sum)
  #   unit        - String, unit type (e.g., "h", "pieces")
  #   unit_price  - Float, price per unit
  #   net_total   - Float, total price for this item
  #   unit_cost   - Float, internal cost per unit
  #   optional    - Boolean, mark as optional
  #   additional  - Boolean, mark as additional service
  #
  # == Read-only attributes:
  #   id, items (Array), created_at, updated_at
  #
  # == Example:
  #   moco.catalog_services.create(
  #     title: "Web Development Package",
  #     items: [
  #       { type: "item", title: "Setup", net_total: 1200.0 },
  #       { type: "item", title: "Development", quantity: 40, unit: "h", unit_price: 150.0, net_total: 6000.0 }
  #     ]
  #   )
  #
  class CatalogService < BaseEntity
    def self.entity_path
      "account/catalog_services"
    end

    def to_s
      name.to_s
    end
  end
end
