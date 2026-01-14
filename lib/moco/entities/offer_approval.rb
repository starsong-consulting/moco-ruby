# frozen_string_literal: true

module MOCO
  # Represents a MOCO offer customer approval (nested under offer)
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
