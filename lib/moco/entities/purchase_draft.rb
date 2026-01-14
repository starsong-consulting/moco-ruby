# frozen_string_literal: true

module MOCO
  # Represents a MOCO purchase draft
  # Auto-created draft purchases from document scanning
  #
  # == Read-only attributes:
  #   id, title, date, company (Hash), file_url,
  #   items (Array), created_at, updated_at
  #
  # == Note:
  #   Purchase drafts are created automatically when documents
  #   are uploaded/scanned in MOCO's inbox.
  #   Convert to actual purchases via the MOCO interface.
  #
  class PurchaseDraft < BaseEntity
    def self.entity_path
      "purchases/drafts"
    end

    def to_s
      "Draft ##{id}"
    end
  end
end
