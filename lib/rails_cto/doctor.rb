# frozen_string_literal: true

require "thor"
require_relative "installer"
require_relative "reporter"

module RailsCTO
  class Doctor
    include Reporter

    def initialize(root, shell: nil)
      @root    = root
      @shell   = shell || Thor::Shell::Basic.new
      @ok      = []
      @missing = []
      @drifted = []
    end

    def run
      check_templates
      check_test_helper
      check_claude_md
      render_report
      clean?
    end

    private

    def check_templates
      Installer::TEMPLATES.each do |source_rel, target_rel|
        classify_template(source_rel, target_rel)
      end
    end

    def classify_template(source_rel, target_rel)
      target = File.join(@root, target_rel)
      source = File.join(RailsCTO.templates_root, source_rel)

      if !File.exist?(target)
        @missing << target_rel
      elsif File.read(target) != File.read(source)
        @drifted << target_rel
      else
        @ok << target_rel
      end
    end

    def check_test_helper
      path = File.join(@root, "test/test_helper.rb")
      if !File.exist?(path)
        @missing << "test/test_helper.rb"
      elsif File.read(path).include?("SimpleCov.start")
        @ok << "test/test_helper.rb (SimpleCov)"
      else
        @missing << "test/test_helper.rb (SimpleCov boot)"
      end
    end

    def check_claude_md
      path = File.join(@root, "CLAUDE.md")
      if File.exist?(path) && File.read(path).include?(Installer::CLAUDE_START_MARKER)
        @ok << "CLAUDE.md (rails-cto block)"
      else
        @missing << "CLAUDE.md (rails-cto block)"
      end
    end

    def clean?
      @missing.empty? && @drifted.empty?
    end

    def render_report
      @shell.say ""
      @shell.say "rails-cto doctor", :bold
      render_section("OK", :green, @ok) { |entry| "    \u2713 #{entry}" }
      render_section("Drifted (differs from bundled template)", :yellow, @drifted) { |entry| "    ~ #{entry}" }
      render_section("Missing", :red, @missing) { |entry| "    - #{entry}" }
      render_summary
    end

    def render_summary
      @shell.say ""
      if clean?
        @shell.say "All rails-cto configs are present and up to date.", :green
      else
        @shell.say "Run `rails-cto init` to install missing configs, or `--force` to reset drifted ones.", :yellow
      end
    end
  end
end
