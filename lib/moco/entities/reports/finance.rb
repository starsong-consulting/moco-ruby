# frozen_string_literal: true

module MOCO
  module Reports
    # Represents a MOCO finance report (read-only)
    class Finance < BaseEntity
      def self.entity_path
        "report/finance"
      end

      def to_s
        "FinanceReport"
      end
    end
  end
end
