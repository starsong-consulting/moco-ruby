# frozen_string_literal: true

module MOCO
  # Represents an attachment on a MOCO offer
  #
  # == Required attributes for create:
  #   attachment - Hash with the following keys:
  #     filename - String, file name including extension (e.g., "appendix.pdf")
  #     base64   - String, base64-encoded file content
  #
  # == Read-only attributes:
  #   id, title, created_at, updated_at
  #
  # == Usage:
  #   offer = moco.offers.find(123)
  #   offer.attachments.all
  #   offer.attachments.create(
  #     attachment: {
  #       filename: "appendix.pdf",
  #       base64: Base64.strict_encode64(File.read("appendix.pdf"))
  #     }
  #   )
  #   offer.attachments.find(42).destroy
  #
  # == Note:
  #   The API only supports list (GET), create (POST), and delete (DELETE).
  #   Update is not available - delete and re-upload to replace.
  #
  class OfferAttachment < BaseEntity
    def to_s
      title.to_s
    end
  end
end
