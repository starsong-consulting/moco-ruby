# frozen_string_literal: true

module MOCO
  # Represents the current user's profile (read-only singleton)
  class Profile < BaseEntity
    def to_s
      "#{firstname} #{lastname}"
    end
  end
end
