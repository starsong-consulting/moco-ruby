# frozen_string_literal: true

module MOCO
  # Represents a MOCO letter paper (letterhead template used on invoices/offers PDFs)
  # Read-only listing of letterheads configured in the MOCO account.
  #
  # == Read-only attributes:
  #   id, name, active, template, file, created_at, updated_at
  #
  # == Usage:
  #   moco.letter_papers.all
  #
  # == Note:
  #   The API only exposes a list endpoint (GET /letter_papers).
  #   Use a letter paper's `id` as `letter_paper_id` when fetching
  #   invoice/offer PDFs (e.g. GET /invoices/{id}.pdf?letter_paper_id=...).
  #
  class LetterPaper < BaseEntity
    def to_s
      name.to_s
    end
  end
end
