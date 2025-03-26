# frozen_string_literal: true

require_relative "lib/moco/version"

Gem::Specification.new do |spec|
  spec.name = "moco-ruby"
  spec.version = MOCO::VERSION
  spec.authors = ["Teal Bauer"]
  spec.email = ["rubygems@teal.is"]

  spec.summary = "A Ruby Gem to interact with the MOCO (mocoapp.com) API."
  spec.homepage = "https://github.com/starsong-consulting/moco-ruby"
  spec.required_ruby_version = ">= 2.6.0"
  spec.license = "Apache-2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/starsong-consulting/moco-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/starsong-consulting/moco-ruby/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 7.0"
  spec.add_dependency "faraday", "~> 2.9.0"
  spec.add_dependency "fuzzy_match", "~> 2.1.0"

  spec.add_development_dependency "test-unit", "~> 3.5"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.metadata["rubygems_mfa_required"] = "true"
end
