# frozen_string_literal: true

module MOCO
  # Represents a MOCO tagging (association between a tag and an entity)
  # This is a read-only entity representing tag assignments.
  #
  # == Read-only attributes:
  #   id, entity_id, entity_type, tag (Hash), created_at, updated_at
  #
  # == Note:
  #   To apply tags to entities, use the `tags` attribute when
  #   creating/updating the entity directly:
  #   moco.projects.update(123, tags: ["Priority", "Important"])
  #
  #   See also: Tag entity for managing available tags.
  #
  class Tagging < BaseEntity
    # Associations
    def tag
      association(:tag)
    end

    def to_s
      "Tagging ##{id}"
    end
  end
end
