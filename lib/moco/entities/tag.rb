# frozen_string_literal: true

module MOCO
  # Represents a MOCO tag/label
  class Tag < BaseEntity
    def to_s
      name.to_s
    end
  end
end
