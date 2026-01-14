# frozen_string_literal: true

module MOCO
  # Represents a MOCO deal category/stage (Akquise-Stufen)
  #
  # == Required attributes for create:
  #   name        - String, category name (e.g., "Contact", "Qualified", "Proposal")
  #   probability - Integer, win probability percentage (0-100)
  #
  # == Read-only attributes:
  #   id, created_at, updated_at
  #
  # == Example:
  #   moco.deal_categories.create(
  #     name: "Qualified Lead",
  #     probability: 25
  #   )
  #
  # == Note:
  #   Categories cannot be deleted if deals are using them.
  #
  class DealCategory < BaseEntity
    def to_s
      name.to_s
    end
  end
end
