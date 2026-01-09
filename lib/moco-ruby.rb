# frozen_string_literal: true

# This file exists so that `gem 'moco-ruby'` auto-requires correctly.
# Bundler converts gem names with hyphens to require paths with slashes,
# so 'moco-ruby' looks for 'moco/ruby'. This shim redirects to the real entry point.
require_relative "moco"
