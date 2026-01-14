# frozen_string_literal: true

module MOCO
  # Represents a MOCO schedule entry (absence/time-off)
  # Note: For project planning, use PlanningEntry instead
  #
  # == Required attributes for create:
  #   date         - String, "YYYY-MM-DD" date of absence
  #   absence_code - Integer, type of absence:
  #                  1 = unplannable absence
  #                  2 = public holiday
  #                  3 = sick day
  #                  4 = holiday/vacation
  #                  5 = other absence
  #
  # == Optional attributes:
  #   user_id - Integer, user ID (default: current user)
  #   am      - Boolean, morning absence (default: true)
  #   pm      - Boolean, afternoon absence (default: true)
  #   comment - String, comment/note
  #   symbol  - Integer, 1-6 for half day visualization
  #
  # == Read-only attributes:
  #   id, assignment (Hash), user (Hash), created_at, updated_at
  #
  # == Example:
  #   # Full day vacation
  #   moco.schedules.create(
  #     date: "2024-01-15",
  #     absence_code: 4,
  #     user_id: 123,
  #     comment: "Annual leave"
  #   )
  #
  #   # Half day sick (morning only)
  #   moco.schedules.create(
  #     date: "2024-01-16",
  #     absence_code: 3,
  #     am: true,
  #     pm: false
  #   )
  #
  class Schedule < BaseEntity
    # Associations
    def user
      @user ||= client.users.find(user_id) if user_id
    end

    def assignment
      return nil unless assignment_id

      @assignment ||= if assignment_type == "Absence"
                        client.absences.find(assignment_id)
                      else
                        client.projects.find(assignment_id)
                      end
    end

    def to_s
      "#{date} - #{user&.full_name} - #{assignment&.name}"
    end
  end
end
