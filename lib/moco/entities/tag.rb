# frozen_string_literal: true

module MOCO
  # Represents a MOCO tag/label
  #
  # == Required attributes for create:
  #   name    - String, tag name (e.g., "Important")
  #   context - String, entity type this tag applies to:
  #             "Project", "Contact", "Company", "Deal", "Offer",
  #             "Invoice", "Purchase", "User"
  #
  # == Read-only attributes:
  #   id, created_at, updated_at
  #
  # == Example:
  #   moco.tags.create(
  #     name: "Priority",
  #     context: "Project"
  #   )
  #
  # == Note:
  #   To apply tags to entities, use the `tags` attribute when
  #   creating/updating the entity: { tags: ["Tag1", "Tag2"] }
  #
  class Tag < BaseEntity
    def to_s
      name.to_s
    end
  end
end
