# frozen_string_literal: true

module MOCO
  class Company < BaseEntity
    # Associations
    def projects
      client.projects.where(company_id: id)
    end
    
    def invoices
      client.invoices.where(company_id: id)
    end
    
    def deals
      client.deals.where(company_id: id)
    end
    
    def contacts
      client.contacts.where(company_id: id)
    end
    
    def to_s
      name
    end
  end
end
