# frozen_string_literal: true

module MOCO
  # Represents a MOCO user employment record
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
