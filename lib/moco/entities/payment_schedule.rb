# frozen_string_literal: true

module MOCO
  # Represents a MOCO project payment schedule entry
  # (Geplante Abrechnungen) for fixed-price project milestones
  #
  # == Required attributes for create:
  #   net_total - Float, payment amount
  #   date      - String, "YYYY-MM-DD" scheduled payment date
  #
  # == Optional attributes:
  #   title       - String, milestone name (e.g., "First installment")
  #   description - String, milestone details (HTML allowed)
  #   checked     - Boolean, mark as completed
  #
  # == Read-only attributes:
  #   id, project (Hash), billed, created_at, updated_at
  #
  # == Access methods:
  #   # All payment schedules across projects
  #   moco.payment_schedules.all
  #
  #   # Filter by project
  #   moco.payment_schedules.where(project_id: 123)
  #
  # == Example:
  #   moco.post("projects/123/payment_schedules", {
  #     net_total: 5000.0,
  #     date: "2024-03-15",
  #     title: "Design Phase Complete"
  #   })
  #
  # == Filtering:
  #   moco.payment_schedules.where(from: "2024-01-01", to: "2024-12-31")
  #   moco.payment_schedules.where(checked: false)  # unpaid only
  #   moco.payment_schedules.where(company_id: 456)
  #
  class PaymentSchedule < BaseEntity
    # Associations
    def project
      association(:project)
    end

    def to_s
      "PaymentSchedule ##{id} (#{date})"
    end
  end
end
