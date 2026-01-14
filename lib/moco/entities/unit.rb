# frozen_string_literal: true

module MOCO
  # Represents a MOCO unit/team (Teams)
  #
  # == Required attributes for create:
  #   name - String, team name (e.g., "Development Team")
  #
  # == Read-only attributes:
  #   id, users (Array of user hashes), created_at, updated_at
  #
  # == Example:
  #   # Create a new team
  #   moco.units.create(name: "Marketing Team")
  #
  #   # Get users in a team
  #   team = moco.units.find(123)
  #   team.users  # => Array of User objects
  #
  # == Note:
  #   To assign users to a team, update the user with unit_id:
  #   moco.users.update(user_id, unit_id: team.id)
  #
  #   Deleting a unit is only possible if no users are assigned to it.
  #
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
