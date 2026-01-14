# frozen_string_literal: true

module MOCO
  module Reports
    # Represents a MOCO utilization report (read-only)
    class Utilization < BaseEntity
      def self.entity_path
        "report/utilization"
      end

      def to_s
        "UtilizationReport"
      end
    end
  end
end
