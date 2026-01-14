# frozen_string_literal: true

module MOCO
  # Represents a MOCO purchase
  # Provides methods for purchase-specific operations
  class Purchase < BaseEntity
    # Assign purchase to a project expense
    def assign_to_project(project_id:, project_expense_id: nil)
      payload = { project_id: }
      payload[:project_expense_id] = project_expense_id if project_expense_id

      client.post("purchases/#{id}/assign_to_project", payload)
      reload
    end

    # Update purchase status (pending/archived)
    def update_status(status)
      client.patch("purchases/#{id}/update_status", { status: })
      reload
    end

    # Store/upload a document for this purchase
    def store_document(file_data)
      client.patch("purchases/#{id}/store_document", file_data)
      self
    end

    # Associations
    def company
      association(:company)
    end

    def user
      association(:user)
    end

    def to_s
      "#{title} (#{date})"
    end
  end
end
