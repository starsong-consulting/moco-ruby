# frozen_string_literal: true

module MOCO
  # Represents a MOCO user
  # Provides methods for user-specific operations and associations
  class User < BaseEntity
    # Instance methods for user-specific operations
    def performance_report
      client.get("users/#{id}/performance_report")
    end

    # Associations
    def activities
      has_many(:activities)
    end

    def presences
      has_many(:presences)
    end

    def holidays
      has_many(:holidays)
    end

    def full_name
      "#{firstname} #{lastname}"
    end

    def to_s
      full_name
    end
  end
end
