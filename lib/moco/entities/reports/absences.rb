# frozen_string_literal: true

module MOCO
  module Reports
    # Represents a MOCO absences report (read-only)
    class Absences < BaseEntity
      def self.entity_path
        "report/absences"
      end

      def to_s
        "AbsencesReport"
      end
    end
  end
end
