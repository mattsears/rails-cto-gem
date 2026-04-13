# frozen_string_literal: true

require "fileutils"
require "thor"
require_relative "reporter"

module RailsCto
  class Installer
    include Reporter

    Report = Struct.new(:created, :patched, :skipped, :errors) do
      def self.empty
        new([], [], [], [])
      end

      def ok?
        errors.empty?
      end
    end

    TEMPLATES = {
      "rubocop.yml" => ".rubocop.yml",
      "reek.yml" => ".reek.yml",
      "bundler-audit.yml" => ".bundler-audit.yml",
      "brakeman.yml" => "config/brakeman.yml",
      "herb/rewriters/align-attributes.mjs" => ".herb/rewriters/align-attributes.mjs",
      "herb/rules/no-inline-styles.mjs" => ".herb/rules/no-inline-styles.mjs"
    }.freeze

    CLAUDE_START_MARKER = "<!-- rails-cto:start -->"
    CLAUDE_END_MARKER   = "<!-- rails-cto:end -->"

    def initialize(root, force: false, shell: nil)
      @root   = root
      @force  = force
      @shell  = shell || Thor::Shell::Basic.new
      @report = Report.empty
    end

    def run
      copy_templates
      patch_test_helper
      patch_claude_md
      render_report
      @report.ok?
    end

    private

    def copy_templates
      TEMPLATES.each do |source_rel, target_rel|
        source = File.join(RailsCto.templates_root, source_rel)
        if File.exist?(source)
          write_file(target_rel, File.read(source))
        else
          @report.errors << "Missing bundled template: #{source_rel}"
        end
      end
    end

    def patch_test_helper
      path = File.join(@root, "test/test_helper.rb")
      return skip_test_helper("not found — run `rails new` first") unless File.exist?(path)

      current = File.read(path)
      return skip_test_helper("SimpleCov already configured") if current.include?("SimpleCov.start")

      snippet = File.read(File.join(RailsCto.templates_root, "simplecov_boot.rb"))
      File.write(path, "#{snippet}\n#{current}")
      @report.patched << "test/test_helper.rb (injected SimpleCov boot)"
    end

    def skip_test_helper(reason)
      @report.skipped << ["test/test_helper.rb", reason]
    end

    def patch_claude_md
      path = File.join(@root, "CLAUDE.md")
      body = File.read(File.join(RailsCto.templates_root, "claude_md_snippet.md"))
      block = "#{CLAUDE_START_MARKER}\n#{body.chomp}\n#{CLAUDE_END_MARKER}\n"
      File.exist?(path) ? append_claude_block(path, block) : create_claude_md(path, block)
    end

    def append_claude_block(path, block)
      current = File.read(path)
      return skip_claude_md if current.include?(CLAUDE_START_MARKER)

      separator = current.end_with?("\n") ? "\n" : "\n\n"
      File.write(path, current + separator + block)
      @report.patched << "CLAUDE.md (appended rails-cto block)"
    end

    def skip_claude_md
      @report.skipped << ["CLAUDE.md", "rails-cto block already present"]
    end

    def create_claude_md(path, block)
      File.write(path, block)
      @report.created << "CLAUDE.md"
    end

    def write_file(relative_target, contents)
      path    = File.join(@root, relative_target)
      existed = File.exist?(path)

      if existed && !@force
        @report.skipped << [relative_target, "already exists"]
        return
      end

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, contents)
      record_write(relative_target, existed)
    rescue SystemCallError => error
      @report.errors << "#{relative_target}: #{error.message}"
    end

    def record_write(relative_target, existed)
      if existed && @force
        @report.patched << "#{relative_target} (overwritten)"
      else
        @report.created << relative_target
      end
    end

    def render_report
      render_header
      render_section("Created", :green,  @report.created) { |path| "    + #{path}" }
      render_section("Patched", :green,  @report.patched) { |path| "    ~ #{path}" }
      render_section("Skipped", :yellow, @report.skipped) { |(path, reason)| "    - #{path}  (#{reason})" }
      render_section("Errors",  :red,    @report.errors)  { |message| "    ! #{message}" }
      render_summary
    end

    def render_header
      @shell.say ""
      @shell.say "rails-cto init", :bold
    end

    def render_summary
      @shell.say ""
      ok = @report.ok?
      @shell.say(ok ? "Done." : "Finished with errors.", ok ? :green : :red)
    end
  end
end
