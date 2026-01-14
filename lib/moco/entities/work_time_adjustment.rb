# frozen_string_literal: true

module MOCO
  # Represents a MOCO user work time adjustment record
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
