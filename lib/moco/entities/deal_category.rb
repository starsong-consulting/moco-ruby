# frozen_string_literal: true

module MOCO
  # Represents a MOCO deal category
  class DealCategory < BaseEntity
    def to_s
      name.to_s
    end
  end
end
