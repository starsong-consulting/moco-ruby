# frozen_string_literal: true

module MOCO
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
