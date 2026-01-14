# frozen_string_literal: true

module MOCO
  # Represents a MOCO custom property (account-level)
  class CustomProperty < BaseEntity
    def self.entity_path
      "account/custom_properties"
    end

    def to_s
      name.to_s
    end
  end
end
