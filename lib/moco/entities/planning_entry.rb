# frozen_string_literal: true

module MOCO
  # Represents a MOCO planning entry (resource scheduling)
  # For absences, use Schedule instead
  #
  # == Required attributes for create:
  #   project_id OR deal_id - Integer, must provide exactly one
  #   starts_on     - String, "YYYY-MM-DD" start date
  #   ends_on       - String, "YYYY-MM-DD" end date
  #   hours_per_day - Float/Integer, planned hours per day
  #
  # == Optional attributes:
  #   user_id   - Integer, user ID (default: current user)
  #   task_id   - Integer, task ID (only with project_id)
  #   comment   - String, notes about the planning
  #   symbol    - Integer, 1-10 for visual indicator:
  #               1=home, 2=building, 3=car, 4=graduation cap, 5=cocktail,
  #               6=bells, 7=baby carriage, 8=users, 9=moon, 10=info circle
  #   tentative - Boolean, true if this is a blocker/tentative
  #
  # == Read-only attributes:
  #   id, color, read_only, user (Hash), project (Hash), deal (Hash),
  #   series_id, series_repeat, created_at, updated_at
  #
  # == Example:
  #   # Plan user on project for a week
  #   moco.planning_entries.create(
  #     project_id: 123,
  #     task_id: 456,
  #     user_id: 789,
  #     starts_on: "2024-01-15",
  #     ends_on: "2024-01-19",
  #     hours_per_day: 6,
  #     comment: "Sprint planning"
  #   )
  #
  #   # Plan user on deal (pre-sales)
  #   moco.planning_entries.create(
  #     deal_id: 123,
  #     starts_on: "2024-01-22",
  #     ends_on: "2024-01-22",
  #     hours_per_day: 4,
  #     tentative: true
  #   )
  #
  class PlanningEntry < BaseEntity
    # Associations
    def user
      @user ||= client.users.find(user_id) if user_id
    end

    def project
      @project ||= client.projects.find(project_id) if project_id
    end

    def deal
      @deal ||= client.deals.find(deal_id) if deal_id
    end

    def to_s
      period = starts_on == ends_on ? starts_on : "#{starts_on} to #{ends_on}"
      resource = project || deal
      "#{period} - #{hours_per_day}h/day - #{user&.full_name} - #{resource&.name}"
    end
  end
end
