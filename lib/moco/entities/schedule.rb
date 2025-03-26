# frozen_string_literal: true

module MOCO
  # Represents a MOCO schedule entry
  # Provides methods for schedule-specific associations
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
