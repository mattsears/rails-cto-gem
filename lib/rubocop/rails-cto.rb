# frozen_string_literal: true

require "rubocop"

require_relative "rails_cto/inject"
RuboCop::RailsCto::Inject.defaults!

require_relative "cop/rails_cto/minitest_subject"
