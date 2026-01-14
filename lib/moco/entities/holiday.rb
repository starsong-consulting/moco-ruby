# frozen_string_literal: true

module MOCO
  # Represents a MOCO user holiday/vacation entitlement record
  # German: "Urlaubsanspruch"
  #
  # == Required attributes for create:
  #   user_id - Integer, the user this holiday entitlement belongs to
  #   year    - Integer, the year (e.g., 2024)
  #   title   - String, description (e.g., "Urlaubsanspruch 80%")
  #   days    - Integer/Float, number of vacation days entitled
  #
  # == Optional attributes:
  #   creator_id - Integer, user who created this record
  #
  # == Read-only attributes:
  #   id, hours (auto-calculated from days), user (Hash), creator (Hash),
  #   created_at, updated_at
  #
  # == Example:
  #   # Create holiday entitlement for a user
  #   moco.holidays.create(
  #     user_id: 123,
  #     year: 2024,
  #     title: "Annual vacation entitlement",
  #     days: 25
  #   )
  #
  # == Filtering:
  #   moco.holidays.where(year: 2024)
  #   moco.holidays.where(user_id: 123)
  #
  # == Note:
  #   Holiday days are converted to hours using the user's daily hours setting.
  #   10 days at 8h/day = 80 hours, 10 days at 5h/day = 50 hours.
  #
  class Holiday < BaseEntity
    # Override entity_path to match API path
    def self.entity_path
      "users/holidays"
    end

    # Associations
    def user
      @user ||= client.users.find(user_id) if user_id
    end

    def creator
      @creator ||= client.users.find(creator_id) if creator_id
    end

    def to_s
      "#{year} - #{title} - #{days} days (#{hours} hours) - #{user&.full_name}"
    end
  end
end
