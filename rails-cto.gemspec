# frozen_string_literal: true

require_relative "lib/rails_cto/version"

Gem::Specification.new do |spec|
  spec.name        = "rails-cto"
  spec.version     = RailsCTO::VERSION
  spec.authors     = ["Matt Sears"]
  spec.email       = ["matt@mattsears.com"]

  spec.summary     = "Companion gem to the rails-cto Claude plugin: configs, templates, and a custom RuboCop cop."
  spec.description = <<~DESC
    rails-cto bundles the quality toolchain (RuboCop, Reek, Flog, Flay, Brakeman,
    bundler-audit, SimpleCov, Herb) that the rails-cto Claude plugin expects,
    and ships matching configuration templates you can drop into any Rails app
    with `rails-cto init`. It also provides a custom RuboCop cop that enforces
    the Minitest::Spec `subject` convention used by the plugin's skills.
  DESC
  spec.homepage    = "https://github.com/mattsears/rails-cto-gem"
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["default_lint_roller_plugin"] = "RuboCop::RailsCTO::Plugin"

  spec.files = Dir[
    "lib/**/*",
    "exe/*",
    "config/**/*",
    "README.md",
    "LICENSE.txt",
    "CHANGELOG.md"
  ]
  spec.bindir      = "exe"
  spec.executables = ["rails-cto"]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 1.3"

  spec.add_dependency "lint_roller", "~> 1.1"
  spec.add_dependency "rubocop", ">= 1.72"
  spec.add_dependency "rubocop-minitest", "~> 0.35"
  # rubocop-rails is intentionally NOT a hard dependency. It pulls activesupport
  # (and transitively connection_pool), which can conflict with host-app pins.
  # Projects that want the Rails cops should add `rubocop-rails` to their own
  # Gemfile alongside rails-cto.

  spec.add_dependency "flay", "~> 2.13"
  spec.add_dependency "flog", "~> 4.8"
  spec.add_dependency "reek", "~> 6.3"

  spec.add_dependency "brakeman", "~> 7.0"
  spec.add_dependency "bundler-audit", "~> 0.9"

  spec.add_dependency "simplecov", "~> 0.22"
  spec.add_dependency "simplecov_json_formatter", "~> 0.1"

  spec.add_dependency "herb", "~> 0.5"
end
