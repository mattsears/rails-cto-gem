# frozen_string_literal: true

require "lint_roller"
require "pathname"

module RuboCop
  module RailsCTO
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: "rails-cto",
          version: ::RailsCTO::VERSION,
          homepage: "https://github.com/mattsears/rails-cto-gem",
          description: "RuboCop cops for the rails-cto Claude plugin."
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join("../../../config/default.yml").expand_path
        )
      end
    end
  end
end
