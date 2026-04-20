# Changelog

## [0.2.1] - 2026-04-20

### Changed
- **Breaking:** `rubocop-rails` is no longer a hard runtime dependency. It
  pulled in `activesupport` (and transitively `connection_pool`), which could
  force host apps into unwanted version upgrades. Projects that want the Rails
  cops should add `rubocop-rails` to their own Gemfile. The bundled
  `.rubocop.yml` still references it via `plugins: - rubocop-rails`.
- Loosened runtime dependency version constraints from `~>` pins to
  `>= current, < next-major` ranges across `thor`, `lint_roller`,
  `rubocop-minitest`, `flay`, `flog`, `reek`, `brakeman`, `bundler-audit`,
  `simplecov`, `simplecov_json_formatter`, and `herb`. Reduces version
  conflicts with host-app Gemfiles.

## [0.2.0] - Unreleased

### Changed
- Migrated to the RuboCop 1.72+ plugin system via `lint_roller`. Consumers
  should use `plugins: - rails-cto` in their `.rubocop.yml` (the bundled
  template is updated). Classic `require: - rails-cto` still works as a
  fallback.
- Renamed Ruby namespaces from `RailsCto` to `RailsCTO` across the gem,
  including the cop identifier `RailsCTO/MinitestSubject`.
- Bumped minimum RuboCop to `>= 1.72`.

### Added
- `lint_roller` runtime dependency and `RuboCop::RailsCTO::Plugin` class.

## [0.1.0] - Unreleased

### Added
- Initial release.
- `rails-cto init` CLI: copies `.rubocop.yml`, `.reek.yml`, `.bundler-audit.yml`,
  `config/brakeman.yml`, and the Herb rewriters/rules into a host project.
- `rails-cto init` patches `test/test_helper.rb` to boot SimpleCov with the
  JSON formatter (writes `coverage/coverage.json` as the plugin's QA skill
  expects).
- `rails-cto init` drops a short block into `CLAUDE.md` describing the
  installed configs and pointing at the `/rails-cto` skill.
- `rails-cto doctor` diagnostics: reports missing or drifted configs so
  Claude skills can self-heal.
- `rails-cto version`.
- Custom RuboCop cop `RailsCTO/MinitestSubject`: enforces the Minitest::Spec
  `subject` rule from the rails-cto-minitest skill.
- Runtime dependencies: rubocop, rubocop-rails, rubocop-minitest, reek, flog,
  flay, brakeman, bundler-audit, simplecov, simplecov_json_formatter, herb,
  thor.
