# frozen_string_literal: true

module MOCO
  # Represents a MOCO offer/quote
  # Provides methods for offer-specific operations
  class Offer < BaseEntity
    # Update the offer status
    def update_status(status)
      client.put("offers/#{id}/update_status", { status: })
      self
    end

    # Get the offer as PDF
    def pdf
      client.get("offers/#{id}.pdf")
    end

    # Send the offer via email
    def send_email(recipient:, subject:, text:, **options)
      payload = {
        recipient:,
        subject:,
        text:
      }.merge(options)

      client.post("offers/#{id}/send_email", payload)
      self
    end

    # Assign offer to company, project, and/or deal
    def assign(company_id: nil, project_id: nil, deal_id: nil)
      payload = {}
      payload[:company_id] = company_id if company_id
      payload[:project_id] = project_id if project_id
      payload[:deal_id] = deal_id if deal_id

      client.put("offers/#{id}/assign", payload)
      reload
    end

    # Get attachments for this offer
    def attachments
      client.get("offers/#{id}/attachments")
    end

    # Add an attachment to the offer
    def add_attachment(file_data)
      client.post("offers/#{id}/attachments", file_data)
      self
    end

    # Delete an attachment from the offer
    def delete_attachment(attachment_id)
      client.delete("offers/#{id}/attachments/#{attachment_id}")
      self
    end

    # Associations
    def company
      association(:customer, "Company")
    end

    def project
      association(:project)
    end

    def deal
      association(:deal)
    end

    def to_s
      "#{identifier} - #{title}"
    end
  end
end
