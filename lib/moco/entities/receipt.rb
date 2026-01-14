# frozen_string_literal: true

module MOCO
  # Represents a MOCO receipt
  class Receipt < BaseEntity
    # Associations
    def user
      association(:user)
    end

    def to_s
      "#{title} (#{date})"
    end
  end
end
