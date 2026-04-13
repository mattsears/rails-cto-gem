# frozen_string_literal: true

require "pathname"
require "yaml"

module RuboCop
  module RailsCto
    CONFIG_DEFAULT = Pathname.new(
      File.expand_path("../../../config/default.yml", __dir__)
    )

    module Inject
      def self.defaults!
        path = CONFIG_DEFAULT.to_s
        hash = ::RuboCop::ConfigLoader.send(:load_yaml_configuration, path)
        config = ::RuboCop::Config.new(hash, path)
        puts "configuration from #{path}" if ::RuboCop::ConfigLoader.debug?
        config = ::RuboCop::ConfigLoader.merge_with_default(config, path)
        ::RuboCop::ConfigLoader.instance_variable_set(:@default_configuration, config)
      end
    end
  end
end
