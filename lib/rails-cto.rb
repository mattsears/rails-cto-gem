# frozen_string_literal: true

# Hyphenated entry point so `require: - rails-cto` in a user's .rubocop.yml
# loads the RuboCop plugin. The Ruby API lives at `require "rails_cto"`.
require_relative "rubocop/rails-cto"
