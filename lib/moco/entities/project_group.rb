# frozen_string_literal: true

module MOCO
  # Represents a MOCO project group for organizing projects
  #
  # == Required attributes for create:
  #   name - String, group name
  #
  # == Read-only attributes:
  #   id, created_at, updated_at
  #
  # == Example:
  #   # Create a project group
  #   moco.project_groups.create(name: "Website Projects")
  #
  #   # Get projects in a group
  #   group = moco.project_groups.find(123)
  #   group.projects  # => Array of Project objects
  #
  # == Note:
  #   To assign a project to a group, set project_group_id when
  #   creating/updating the project.
  #
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
