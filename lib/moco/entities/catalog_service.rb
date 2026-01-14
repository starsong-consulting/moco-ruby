# frozen_string_literal: true

module MOCO
  # Represents a MOCO catalog service (account-level)
  class CatalogService < BaseEntity
    def self.entity_path
      "account/catalog_services"
    end

    def to_s
      name.to_s
    end
  end
end
