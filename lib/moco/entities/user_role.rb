# frozen_string_literal: true

module MOCO
  # Represents a MOCO user permission role (read-only)
  class UserRole < BaseEntity
    def self.entity_path
      "users/roles"
    end

    def to_s
      name.to_s
    end
  end
end
