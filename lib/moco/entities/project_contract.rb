# frozen_string_literal: true

module MOCO
  # Represents a MOCO project contract/staff assignment
  # (Projekte / Personal) - assigning users to projects
  #
  # == Required attributes for create:
  #   user_id - Integer, user to assign to project
  #
  # == Optional attributes:
  #   billable    - Boolean, whether user's time is billable
  #   active      - Boolean, whether assignment is active
  #   budget      - Float, hours budget for this user on project
  #   hourly_rate - Float, billing rate for this user on project
  #
  # == Read-only attributes:
  #   id, firstname, lastname, created_at, updated_at
  #
  # == Access via project:
  #   project = moco.projects.find(123)
  #   project.contracts  # via nested API
  #
  # == Example:
  #   # Assign user to project with budget
  #   moco.post("projects/123/contracts", {
  #     user_id: 456,
  #     budget: 100,
  #     hourly_rate: 150.0,
  #     billable: true
  #   })
  #
  # == Note:
  #   Cannot delete assignment if user has tracked hours.
  #   user_id cannot be changed after creation.
  #
  class ProjectContract < BaseEntity
    # Associations
    def project
      association(:project)
    end

    def user
      association(:user)
    end

    def to_s
      "Contract ##{id}"
    end
  end
end
