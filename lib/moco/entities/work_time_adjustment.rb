# frozen_string_literal: true

module MOCO
  # Represents a MOCO user work time adjustment record
  # (Korrekturen Zeiterfassung) for overtime/undertime corrections
  #
  # == Required attributes for create:
  #   user_id     - Integer, user to adjust
  #   date        - String, "YYYY-MM-DD" effective date
  #   description - String, reason for adjustment
  #   hours       - Float, hours to add (positive) or subtract (negative)
  #
  # == Read-only attributes:
  #   id, user (Hash), creator (Hash), created_at, updated_at
  #
  # == Example:
  #   # Add overtime from previous year
  #   moco.work_time_adjustments.create(
  #     user_id: 123,
  #     date: "2024-01-01",
  #     description: "Overtime carryover from 2023",
  #     hours: 42.0
  #   )
  #
  #   # Correct time balance
  #   moco.work_time_adjustments.create(
  #     user_id: 123,
  #     date: "2024-06-15",
  #     description: "Correction for unpaid leave",
  #     hours: -16.0
  #   )
  #
  # == Filtering:
  #   moco.work_time_adjustments.where(user_id: 123)
  #   moco.work_time_adjustments.where(from: "2024-01-01", to: "2024-12-31")
  #
  class WorkTimeAdjustment < BaseEntity
    def self.entity_path
      "users/work_time_adjustments"
    end

    # Associations
    def user
      association(:user)
    end

    def to_s
      "WorkTimeAdjustment ##{id} (#{date})"
    end
  end
end
