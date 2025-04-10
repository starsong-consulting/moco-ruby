# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "active_support/inflector"

require_relative "moco/version"

# New API (v2)
require_relative "moco/entities/base_entity"
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
require_relative "moco/client"
require_relative "moco/connection"
require_relative "moco/entity_collection"

require_relative "moco/sync"

module MOCO
  class Error < StandardError; end
end
