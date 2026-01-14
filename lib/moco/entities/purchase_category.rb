# frozen_string_literal: true

module MOCO
  # Represents a MOCO purchase category
  class PurchaseCategory < BaseEntity
    def self.entity_path
      "purchases/categories"
    end

    def to_s
      name.to_s
    end
  end
end
