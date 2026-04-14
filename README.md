# rails-cto

Companion Ruby gem to the [rails-cto Claude plugin](https://github.com/mattsears/rails-cto). Bundles the quality toolchain the plugin's skills depend on (RuboCop, Reek, Flog, Flay, Brakeman, bundler-audit, SimpleCov, Herb) and ships matching configuration templates you can drop into any Rails app with a single command.

## Install

Add to your Gemfile:

```ruby
group :development, :test do
  gem "rails-cto"
end
```

Then:

```bash
bundle install
bundle exec rails-cto init
```

## What `rails-cto init` does

- Copies config templates into your project (skipping any that already exist):
  - `.rubocop.yml`
  - `.reek.yml`
  - `.bundler-audit.yml`
  - `config/brakeman.yml`
  - `.herb/rewriters/align-attributes.mjs`
  - `.herb/rules/no-inline-styles.mjs`
- Patches `test/test_helper.rb` to boot SimpleCov with the JSON formatter (so the plugin's QA skill can read `coverage/coverage.json`).
- Appends a short block to `CLAUDE.md` telling Claude Code this project uses the rails-cto plugin.

Pass `--force` to overwrite existing files.

## Commands

| Command                  | Purpose                                                                                                                  |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------|
| `rails-cto init`         | Install configs and templates (skip existing).                                                                           |
| `rails-cto init --force` | Install configs, overwriting existing files.                                                                             |
| `rails-cto doctor`       | Report which configs are present, missing, or drifted from the bundled templates. Exits non-zero if anything is missing. |
| `rails-cto version`      | Print the gem version.                                                                                                   |

## Custom RuboCop cop: `RailsCTO/MinitestSubject`

The bundled `.rubocop.yml` auto-enables this cop. It enforces the mandatory Minitest::Spec `subject` rule from the plugin:

- Every `*_test.rb` class must define `subject { ... }` exactly once at the top of the class.
- `subject` must not be reassigned inside nested `describe`/`it` blocks.

Disable per file with a standard RuboCop comment:

```ruby
# rubocop:disable RailsCTO/MinitestSubject
```

## Links

- Claude plugin: https://github.com/mattsears/rails-cto
- Gem source: https://github.com/mattsears/rails-cto-gem

## License

MIT.
