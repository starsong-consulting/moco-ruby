# frozen_string_literal: true

module MOCO
  module Reports
    # Represents a MOCO cashflow report (read-only)
    class Cashflow < BaseEntity
      def self.entity_path
        "report/cashflow"
      end

      def to_s
        "CashflowReport"
      end
    end
  end
end
