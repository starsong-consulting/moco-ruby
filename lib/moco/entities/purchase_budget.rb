# frozen_string_literal: true

module MOCO
  # Purchase budgets (Ausgaben – Budgets)
  # Read-only endpoint: /purchases/budgets
  class PurchaseBudget < BaseEntity
    # Custom path since it's nested under purchases
    def self.entity_path
      "purchases/budgets"
    end

    def to_s
      "PurchaseBudget #{id}: #{title} (#{year})"
    end

    def remaining_percentage
      return 0 if target.to_f.zero?

      (remaining.to_f / target.to_f * 100).round(1)
    end

    def exhausted_percentage
      return 0 if target.to_f.zero?

      (exhaused.to_f / target.to_f * 100).round(1)
    end
  end
end
