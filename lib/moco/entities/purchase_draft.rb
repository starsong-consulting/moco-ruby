# frozen_string_literal: true

module MOCO
  # Represents a MOCO purchase draft
  class PurchaseDraft < BaseEntity
    def self.entity_path
      "purchases/drafts"
    end

    def to_s
      "Draft ##{id}"
    end
  end
end
