# frozen_string_literal: true

module MOCO
  # Represents a MOCO user (staff member)
  #
  # == Required attributes for create:
  #   firstname - String, first name
  #   lastname  - String, last name
  #   email     - String, email address (used for login)
  #   unit_id   - Integer, team/unit ID
  #
  # == Optional attributes:
  #   password     - String, initial password (if not set, user gets welcome email)
  #   role_id      - Integer, permission role ID
  #   active       - Boolean, whether user is active
  #   external     - Boolean, true for contractors/external staff
  #   language     - String, one of: "de", "de-AT", "de-CH", "en", "it", "fr"
  #   mobile_phone - String, mobile phone number
  #   work_phone   - String, work phone number
  #   home_address - String, home address (use \n for line breaks)
  #   bday         - String, birthday "YYYY-MM-DD"
  #   iban         - String, bank account IBAN
  #   tags         - Array of Strings, e.g., ["Developer", "Remote"]
  #   custom_properties - Hash, e.g., {"Start Date": "2024-01-01"}
  #   info         - String, additional notes
  #   welcome_email - Boolean, send welcome email (default: true if no password)
  #   avatar       - Hash, { filename: "photo.jpg", base64: "..." }
  #
  # == Read-only attributes:
  #   id, avatar_url, unit (Hash), role (Hash), created_at, updated_at
  #
  # == Example:
  #   moco.users.create(
  #     firstname: "John",
  #     lastname: "Doe",
  #     email: "john.doe@company.com",
  #     unit_id: 123,
  #     language: "en",
  #     tags: ["Developer"]
  #   )
  #
  class User < BaseEntity
    # Instance methods for user-specific operations
    def performance_report
      client.get("users/#{id}/performance_report")
    end

    # Associations
    def activities
      has_many(:activities)
    end

    def presences
      has_many(:presences)
    end

    def holidays
      has_many(:holidays)
    end

    def employments
      has_many(:employments)
    end

    def work_time_adjustments
      has_many(:work_time_adjustments)
    end

    def unit
      association(:unit)
    end

    def full_name
      "#{firstname} #{lastname}"
    end

    def to_s
      full_name
    end
  end
end
