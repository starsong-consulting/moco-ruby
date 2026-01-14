# frozen_string_literal: true

module MOCO
  # Represents a MOCO offer customer approval (Kundenfreigabe)
  # Allows customers to review and sign offers online
  #
  # == Read-only attributes:
  #   id, approval_url, offer_document_url, active,
  #   customer_full_name, customer_email, signature_url,
  #   signed_at, created_at, updated_at
  #
  # == Activation workflow:
  #   1. Activate approval to generate shareable URL
  #   2. Share offer_document_url with customer
  #   3. Customer reviews and signs
  #   4. Check signed_at to verify approval
  #
  # == Example:
  #   # Activate customer approval
  #   approval = moco.post("offers/123/customer_approval/activate")
  #
  #   # Get approval status
  #   approval = moco.get("offers/123/customer_approval")
  #
  #   # Deactivate (revoke access)
  #   moco.put("offers/123/customer_approval/deactivate")
  #
  # == Note:
  #   Check signed_at to determine if the customer has signed.
  #   Returns 404 if not yet activated.
  #
  class OfferApproval < BaseEntity
    # Associations
    def offer
      association(:offer)
    end

    def to_s
      "OfferApproval ##{id}"
    end
  end
end
