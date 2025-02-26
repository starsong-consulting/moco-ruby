# frozen_string_literal: true

module MOCO
  class Invoice < BaseEntity
    # Instance methods for invoice-specific operations
    def update_status(status)
      client.put("invoices/#{id}/update_status", { status: status })
      self
    end
    
    def pdf
      client.get("invoices/#{id}.pdf")
    end
    
    def timesheet
      client.get("invoices/#{id}/timesheet")
    end
    
    def timesheet_pdf
      client.get("invoices/#{id}/timesheet.pdf")
    end
    
    def expenses
      client.get("invoices/#{id}/expenses")
    end
    
    def send_email(recipient:, subject:, text:, **options)
      payload = {
        recipient: recipient,
        subject: subject,
        text: text
      }.merge(options)
      
      client.post("invoices/#{id}/send_email", payload)
      self
    end
    
    # Associations
    def company
      @company ||= client.companies.find(company_id) if company_id
    end
    
    def project
      @project ||= client.projects.find(project_id) if project_id
    end
    
    def to_s
      "#{identifier} - #{title} (#{date})"
    end
  end
end
