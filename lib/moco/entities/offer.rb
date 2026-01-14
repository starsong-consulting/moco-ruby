# frozen_string_literal: true

module MOCO
  # Represents a MOCO offer/quote
  #
  # == Required attributes for create:
  #   recipient_address - String, full address (use \r\n for line breaks)
  #   date              - String, "YYYY-MM-DD" offer date
  #   due_date          - String, "YYYY-MM-DD" valid until date
  #   title             - String, offer title (e.g., "Offer - Website Relaunch")
  #   tax               - Float, tax rate percentage (e.g., 19.0)
  #   items             - Array of Hashes, offer line items (see below)
  #
  # == Item types (for items array):
  #   { type: "title", title: "Section Title" }
  #   { type: "description", description: "Description text" }
  #   { type: "item", title: "Service", quantity: 10, unit: "h", unit_price: 150.0 }
  #   { type: "item", title: "Fixed Fee", net_total: 500.0 }  # lump sum
  #   { type: "subtotal" }
  #   { type: "separator" }
  #   { type: "page-break" }
  #
  # == Optional attributes:
  #   company_id  - Integer, customer company ID (set from project if project_id provided)
  #   deal_id     - Integer, associated deal ID
  #   project_id  - Integer, associated project ID
  #   currency    - String, 3-letter code (required if no company/deal/project)
  #   salutation  - String, greeting text
  #   footer      - String, footer text
  #   discount    - Float, discount percentage
  #   contact_id  - Integer, customer contact ID
  #   change_address - String, "offer" or "customer"
  #   tags        - Array of Strings
  #
  # == Read-only attributes:
  #   id, identifier, status, net_total, gross_total, created_at, updated_at
  #
  # == Example:
  #   moco.offers.create(
  #     deal_id: 123456,
  #     recipient_address: "Acme Corp\r\n123 Main St",
  #     date: "2024-01-15",
  #     due_date: "2024-02-15",
  #     title: "Offer - Website Relaunch",
  #     tax: 19.0,
  #     items: [
  #       { type: "title", title: "Development Services" },
  #       { type: "item", title: "Frontend Development", quantity: 40, unit: "h", unit_price: 150.0 },
  #       { type: "item", title: "Backend Development", quantity: 60, unit: "h", unit_price: 150.0 }
  #     ]
  #   )
  #
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
