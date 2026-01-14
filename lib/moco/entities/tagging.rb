# frozen_string_literal: true

module MOCO
  # Represents a MOCO tagging (association between a tag and an entity)
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
