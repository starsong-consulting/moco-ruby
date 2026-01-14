# frozen_string_literal: true

module MOCO
  # Represents a MOCO project recurring expense (nested under project)
  class RecurringExpense < BaseEntity
    # Associations
    def project
      association(:project)
    end

    def to_s
      "RecurringExpense ##{id} - #{title}"
    end
  end
end
