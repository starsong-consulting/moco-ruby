# frozen_string_literal: true

module MOCO
  # Represents a MOCO user permission role
  # Read-only list of available permission roles
  #
  # == Read-only attributes:
  #   id, name, created_at, updated_at
  #
  # == Common roles:
  #   - Admin
  #   - Manager
  #   - Coworker
  #   - etc.
  #
  # == Note:
  #   Permission roles are configured in MOCO's admin interface.
  #   Use role_id when creating/updating users to assign a role.
  #
  class UserRole < BaseEntity
    def self.entity_path
      "users/roles"
    end

    def to_s
      name.to_s
    end
  end
end
