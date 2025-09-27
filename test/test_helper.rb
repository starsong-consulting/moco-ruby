# frozen_string_literal: true

require "test-unit"
require "dotenv/load"

# Load the library
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "moco"

# Ensure test environment variables are set
unless ENV["MOCO_API_TEST_SUBDOMAIN"] && ENV["MOCO_API_TEST_API_KEY"]
  warn "Warning: MOCO_API_TEST_SUBDOMAIN and MOCO_API_TEST_API_KEY must be set in .env"
end
