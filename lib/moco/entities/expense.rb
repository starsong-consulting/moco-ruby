# frozen_string_literal: true

module MOCO
  class Expense < BaseEntity
    # Class methods for bulk operations
    def self.disregard(client, expense_ids:)
      client.post("projects/expenses/disregard", { expense_ids: expense_ids })
    end
    
    def self.bulk_create(client, project_id, expenses)
      client.post("projects/#{project_id}/expenses/bulk", { expenses: expenses })
    end
    
    # Associations
    def project
      @project ||= client.projects.find(project_id) if project_id
    end
    
    def user
      @user ||= client.users.find(user_id) if user_id
    end
    
    def to_s
      "#{date} - #{title} (#{amount})"
    end
  end
end
