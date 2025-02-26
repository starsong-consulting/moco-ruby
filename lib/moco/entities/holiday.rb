# frozen_string_literal: true

module MOCO
  class Holiday < BaseEntity
    # Override entity_path to match API path
    def entity_path
      "users/holidays"
    end
    
    # Associations
    def user
      @user ||= client.users.find(user_id) if user_id
    end
    
    def creator
      @creator ||= client.users.find(creator_id) if creator_id
    end
    
    def to_s
      "#{year} - #{title} - #{days} days (#{hours} hours) - #{user&.full_name}"
    end
  end
end
