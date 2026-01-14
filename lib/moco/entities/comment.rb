# frozen_string_literal: true

module MOCO
  # Represents a MOCO comment/note (Notizen)
  # Comments can be attached to various entities
  #
  # == Required attributes for create:
  #   commentable_id   - Integer, ID of the entity to attach comment to
  #   commentable_type - String, entity type:
  #                      "Project", "Contact", "Company", "Deal", "User", "Unit",
  #                      "Invoice", "Offer", "Expense", "Receipt", "Purchase",
  #                      "DeliveryNote", "OfferConfirmation", "InvoiceReminder",
  #                      "InvoiceDeletion", "InvoiceBookkeepingExport",
  #                      "RecurringExpense", "ReceiptRefundRequest",
  #                      "PurchaseBookkeepingExport", "PurchaseDraft"
  #   text             - String, comment text (plain text or HTML)
  #
  # == Optional attributes:
  #   attachment_filename - String, filename for attachment
  #   attachment_content  - String, base64-encoded file content
  #   created_at          - String, timestamp for data migration
  #
  # == Read-only attributes:
  #   id, manual, user (Hash - creator), created_at, updated_at
  #
  # == Allowed HTML tags in text:
  #   div, strong, em, u, pre, ul, ol, li, br
  #
  # == Example:
  #   # Add comment to a project
  #   moco.comments.create(
  #     commentable_id: 123,
  #     commentable_type: "Project",
  #     text: "<div>Project kickoff on <strong>Jan 15</strong></div>"
  #   )
  #
  # == Filtering:
  #   moco.comments.where(commentable_type: "Project", commentable_id: 123)
  #   moco.comments.where(user_id: 456)
  #   moco.comments.where(manual: true)  # user-created only
  #
  class Comment < BaseEntity
    # Bulk create comments
    # @param client [MOCO::Client] the client instance
    # @param comments [Array<Hash>] array of comment attributes
    # @return [Array<Comment>] created comments
    def self.bulk_create(client, comments)
      response = client.post("comments/bulk", { bulk: comments })
      response.map { |data| new(client, data) }
    end

    # Associations
    def user
      association(:user)
    end

    def to_s
      text.to_s.truncate(50)
    end
  end
end
