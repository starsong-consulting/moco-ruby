# frozen_string_literal: true

module MOCO
  # Represents a MOCO unit/team
  class Unit < BaseEntity
    # Get users belonging to this unit
    def users
      has_many(:users, :unit_id)
    end

    def to_s
      name.to_s
    end
  end
end
