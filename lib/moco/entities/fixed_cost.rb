# frozen_string_literal: true

module MOCO
  # Represents a MOCO fixed cost entry (Fixkosten)
  # Read-only access to company fixed costs for reporting
  #
  # == Read-only attributes:
  #   id, title, description, costs (Array of monthly amounts),
  #   created_at, updated_at
  #
  # == Costs array format:
  #   [{ year: 2024, month: 1, amount: 50000.0 }, ...]
  #
  # == Filtering:
  #   moco.fixed_costs.where(year: 2024)
  #
  # == Note:
  #   Fixed costs are configured in MOCO's admin interface.
  #   This endpoint provides read-only access for reporting.
  #
  class FixedCost < BaseEntity
    def self.entity_path
      "account/fixed_costs"
    end

    def to_s
      name.to_s
    end
  end
end
