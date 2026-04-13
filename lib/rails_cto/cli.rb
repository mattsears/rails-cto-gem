# frozen_string_literal: true

require "thor"
require_relative "../rails_cto"
require_relative "installer"
require_relative "doctor"

module RailsCto
  class CLI < Thor
    package_name "rails-cto"

    def self.exit_on_failure?
      true
    end

    desc "init", "Copy rails-cto configs and templates into the current project"
    long_desc <<~LONG
      Installs the rails-cto config files (.rubocop.yml, .reek.yml,
      .bundler-audit.yml, config/brakeman.yml) and Herb plugins (.herb/)
      into the current directory. Patches test/test_helper.rb to boot
      SimpleCov with the JSON formatter, and appends a short block to
      CLAUDE.md describing the installed configs.

      Existing files are skipped and reported. Use --force to overwrite.
    LONG
    method_option :force,
                  type: :boolean,
                  default: false,
                  aliases: "-f",
                  desc: "Overwrite existing files"
    def init
      installer = Installer.new(Dir.pwd, force: options[:force], shell: shell)
      exit(installer.run ? 0 : 1)
    end

    desc "doctor", "Check which rails-cto configs are installed, missing, or drifted"
    def doctor
      result = Doctor.new(Dir.pwd, shell: shell).run
      exit(result ? 0 : 1)
    end

    desc "version", "Print the rails-cto gem version"
    def version
      say "rails-cto #{RailsCto::VERSION}"
    end

    map %w[--version -v] => :version
  end
end
