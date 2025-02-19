# frozen_string_literal: true

module MOCO
  class User < BaseEntity
    # Instance methods for user-specific operations
    def performance_report
      client.get("users/#{id}/performance_report")
    end
    
    # Associations
    def activities
      client.activities.where(user_id: id)
    end
    
    def presences
      client.presences.where(user_id: id)
    end
    
    def holidays
      client.holidays.where(user_id: id)
    end
    
    def full_name
      "#{firstname} #{lastname}"
    end
    
    def to_s
      full_name
    end
  end
end
