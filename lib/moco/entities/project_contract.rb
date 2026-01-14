# frozen_string_literal: true

module MOCO
  # Represents a MOCO project contract (nested under project)
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
