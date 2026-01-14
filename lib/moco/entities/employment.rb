# frozen_string_literal: true

module MOCO
  # Represents a MOCO user employment/work schedule record
  # Access via: moco.employments.where(user_id: 123) or user.employments
  #
  # == Required attributes for create:
  #   user_id - Integer, the user this employment belongs to
  #   pattern - Hash, weekly work schedule:
  #             { "am": [0, 4, 4, 4, 4], "pm": [0, 4, 4, 4, 4] }
  #             Arrays represent Mon-Fri morning/afternoon hours
  #
  # == Optional attributes:
  #   from - String, "YYYY-MM-DD" when employment starts (default: today)
  #   to   - String, "YYYY-MM-DD" when employment ends (null = ongoing)
  #
  # == Read-only attributes:
  #   id, weekly_target_hours, user (Hash), created_at, updated_at
  #
  # == Example:
  #   # Create full-time employment (8h/day Mon-Fri)
  #   moco.employments.create(
  #     user_id: 123,
  #     pattern: {
  #       am: [4, 4, 4, 4, 4],
  #       pm: [4, 4, 4, 4, 4]
  #     },
  #     from: "2024-01-01"
  #   )
  #
  #   # Create part-time (4h/day Tue-Thu)
  #   moco.employments.create(
  #     user_id: 123,
  #     pattern: {
  #       am: [0, 4, 4, 4, 0],
  #       pm: [0, 0, 0, 0, 0]
  #     },
  #     from: "2024-01-01"
  #   )
  #
  class Employment < BaseEntity
    def self.entity_path
      "users/employments"
    end

    # Associations
    def user
      association(:user)
    end

    def to_s
      "Employment ##{id} (#{from} - #{self.to || 'present'})"
    end
  end
end
