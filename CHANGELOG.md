# Changelog

## [0.1.0] - Unreleased

### Added
- Initial release.
- `rails-cto init` CLI: copies `.rubocop.yml`, `.reek.yml`, `.bundler-audit.yml`,
  `config/brakeman.yml`, and the Herb rewriters/rules into a host project.
- `rails-cto init` patches `test/test_helper.rb` to boot SimpleCov with the
  JSON formatter (writes `coverage/coverage.json` as the plugin's QA skill
  expects).
- `rails-cto init` drops a short block into `CLAUDE.md` describing the
  installed configs and pointing at the `/fullstack-rails-cto` skill.
- `rails-cto doctor` diagnostics: reports missing or drifted configs so
  Claude skills can self-heal.
- `rails-cto version`.
- Custom RuboCop cop `RailsCto/MinitestSubject`: enforces the Minitest::Spec
  `subject` rule from the rails-cto-minitest skill.
- Runtime dependencies: rubocop, rubocop-rails, rubocop-minitest, reek, flog,
  flay, brakeman, bundler-audit, simplecov, simplecov_json_formatter, herb,
  thor.
