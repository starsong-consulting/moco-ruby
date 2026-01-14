# frozen_string_literal: true

module MOCO
  # Represents a MOCO presence entry (work time tracking)
  #
  # == Required attributes for create:
  #   date - String, "YYYY-MM-DD" date
  #   from - String, "HH:MM" start time (e.g., "08:00")
  #
  # == Optional attributes:
  #   to            - String, "HH:MM" end time (e.g., "17:00"), can be blank for open entry
  #   is_home_office - Boolean, whether working from home (default: false)
  #
  # == Read-only attributes:
  #   id, user (Hash), created_at, updated_at
  #
  # == Class methods:
  #   Presence.touch(client) - Clock in/out (creates or closes presence)
  #
  # == Example:
  #   # Log work time
  #   moco.presences.create(
  #     date: "2024-01-15",
  #     from: "09:00",
  #     to: "17:30"
  #   )
  #
  #   # Start work (open-ended)
  #   moco.presences.create(
  #     date: "2024-01-16",
  #     from: "08:30",
  #     is_home_office: true
  #   )
  #
  #   # Clock in/out via touch
  #   MOCO::Presence.touch(moco)
  #
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
