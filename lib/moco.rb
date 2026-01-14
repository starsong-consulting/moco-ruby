# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "active_support/inflector"

require_relative "moco/version"

# Core classes needed by entities
require_relative "moco/connection"
require_relative "moco/collection_proxy"
require_relative "moco/nested_collection_proxy"

# Entities
require_relative "moco/entities/base_entity"

# Core entities (original)
require_relative "moco/entities/project"
require_relative "moco/entities/activity"
require_relative "moco/entities/user"
require_relative "moco/entities/company"
require_relative "moco/entities/task"
require_relative "moco/entities/invoice"
require_relative "moco/entities/deal"
require_relative "moco/entities/expense"
require_relative "moco/entities/web_hook"
require_relative "moco/entities/schedule"
require_relative "moco/entities/presence"
require_relative "moco/entities/holiday"
require_relative "moco/entities/planning_entry"

# New standalone entities
require_relative "moco/entities/contact"
require_relative "moco/entities/offer"
require_relative "moco/entities/purchase"
require_relative "moco/entities/receipt"
require_relative "moco/entities/unit"
require_relative "moco/entities/comment"
require_relative "moco/entities/tag"
require_relative "moco/entities/tagging"
require_relative "moco/entities/deal_category"
require_relative "moco/entities/project_group"
require_relative "moco/entities/profile"

# Account-level entities
require_relative "moco/entities/catalog_service"
require_relative "moco/entities/custom_property"
require_relative "moco/entities/expense_template"
require_relative "moco/entities/fixed_cost"
require_relative "moco/entities/hourly_rate"
require_relative "moco/entities/internal_hourly_rate"
require_relative "moco/entities/task_template"
require_relative "moco/entities/user_role"
require_relative "moco/entities/vat_code_sale"
require_relative "moco/entities/vat_code_purchase"

# Nested/sub-resource entities
require_relative "moco/entities/employment"
require_relative "moco/entities/work_time_adjustment"
require_relative "moco/entities/project_contract"
require_relative "moco/entities/payment_schedule"
require_relative "moco/entities/recurring_expense"
require_relative "moco/entities/invoice_payment"
require_relative "moco/entities/invoice_reminder"
require_relative "moco/entities/offer_approval"
require_relative "moco/entities/purchase_category"
require_relative "moco/entities/purchase_draft"

# Reports
require_relative "moco/entities/reports/absences"
require_relative "moco/entities/reports/cashflow"
require_relative "moco/entities/reports/finance"
require_relative "moco/entities/reports/utilization"

require_relative "moco/client"
require_relative "moco/entity_collection"

require_relative "moco/sync"

module MOCO
  class Error < StandardError; end
end
