# frozen_string_literal: true

module MOCO
  # Represents a MOCO contact (person)
  # Contacts are people associated with companies
  class Contact < BaseEntity
    # Override entity_path to match API path
    def self.entity_path
      "contacts/people"
    end

    # Associations
    def company
      association(:company)
    end

    def to_s
      "#{firstname} #{lastname}"
    end
  end
end
