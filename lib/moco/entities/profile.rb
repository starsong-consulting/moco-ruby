# frozen_string_literal: true

module MOCO
  # Represents the current API user's profile
  # Read-only singleton endpoint for the authenticated user
  #
  # == Read-only attributes:
  #   id, firstname, lastname, email, unit (Hash),
  #   created_at, updated_at
  #
  # == Usage:
  #   profile = moco.profile.get
  #   puts "Logged in as: #{profile.firstname} #{profile.lastname}"
  #
  # == Note:
  #   This returns information about the user who owns the API key.
  #   For other user information, use moco.users.
  #
  class Profile < BaseEntity
    def to_s
      "#{firstname} #{lastname}"
    end
  end
end
