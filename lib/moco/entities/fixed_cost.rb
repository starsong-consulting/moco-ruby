# frozen_string_literal: true

module MOCO
  # Represents a MOCO fixed cost (account-level)
  class FixedCost < BaseEntity
    def self.entity_path
      "account/fixed_costs"
    end

    def to_s
      name.to_s
    end
  end
end
