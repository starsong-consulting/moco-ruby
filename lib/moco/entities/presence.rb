# frozen_string_literal: true

module MOCO
  # Represents a MOCO presence entry
  # Provides methods for presence-specific operations and associations
  class Presence < BaseEntity
    # Define the specific API path for this entity as a class method
    def self.entity_path
      "users/presences"
    end

    # Class methods for special operations
    def self.touch(client, is_home_office: false, override: nil)
      payload = {}
      payload[:is_home_office] = is_home_office if is_home_office
      payload[:override] = override if override

      client.post("users/presences/touch", payload)
    end

    # Associations
    def user
      @user ||= client.users.find(user_id) if user_id
    end

    def to_s
      "#{date} - #{from} to #{to} - #{user&.full_name}"
    end
  end
end
