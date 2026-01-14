# frozen_string_literal: true

module MOCO
  # Represents a MOCO project group
  class ProjectGroup < BaseEntity
    def self.entity_path
      "projects/groups"
    end

    # Get projects in this group
    def projects
      has_many(:projects, :project_group_id)
    end

    def to_s
      name.to_s
    end
  end
end
