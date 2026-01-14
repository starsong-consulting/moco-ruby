# frozen_string_literal: true

module MOCO
  # Represents a MOCO contact (person/Ansprechpartner)
  # Contacts are people associated with companies
  #
  # == Required attributes for create:
  #   lastname - String, last name (e.g., "Muster")
  #   gender   - String, one of: "F" (female), "M" (male), "U" (unknown/diverse)
  #
  # == Optional attributes:
  #   firstname    - String, first name
  #   company_id   - Integer, associated company ID
  #   user_id      - Integer, responsible user ID (default: current user)
  #   title        - String, title (e.g., "Dr.", "Prof.")
  #   job_position - String, job title (e.g., "Account Manager")
  #   mobile_phone - String, mobile phone number
  #   work_phone   - String, work phone number
  #   work_fax     - String, work fax number
  #   work_email   - String, work email address
  #   work_address - String, work address (use \n for line breaks)
  #   home_email   - String, personal email
  #   home_address - String, home address
  #   birthday     - String, "YYYY-MM-DD" format (e.g., "1990-05-22")
  #   info         - String, additional notes
  #   tags         - Array of Strings, e.g., ["VIP", "Newsletter"]
  #
  # == Read-only attributes (returned by API):
  #   id, avatar_url, company (Hash), created_at, updated_at
  #
  # == Example:
  #   moco.contacts.create(
  #     firstname: "John",
  #     lastname: "Doe",
  #     gender: "M",
  #     company_id: 123456,
  #     work_email: "john.doe@example.com",
  #     job_position: "CTO"
  #   )
  #
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
