# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "active_support/inflector"

require_relative "moco/version"
require_relative "moco/entities/base_entity"
require_relative "moco/client"
require_relative "moco/connection"
require_relative "moco/entity_collection"

module MOCO
  class Error < StandardError; end
end
