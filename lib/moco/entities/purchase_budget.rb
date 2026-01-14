# frozen_string_literal: true

module MOCO
  # Represents a MOCO purchase budget (Ausgaben – Budgets)
  # Read-only budget tracking for expense categories
  #
  # == Read-only attributes:
  #   id, title, year, target, exhausted, remaining,
  #   created_at, updated_at
  #
  # == Helper methods:
  #   remaining_percentage   - Percentage of budget remaining
  #   exhausted_percentage   - Percentage of budget used
  #
  # == Example:
  #   budgets = moco.purchase_budgets.all
  #   budgets.each do |budget|
  #     puts "#{budget.title}: #{budget.remaining_percentage}% remaining"
  #   end
  #
  # == Note:
  #   Purchase budgets are configured in MOCO's admin interface.
  #   This endpoint provides read-only access for tracking.
  #
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
