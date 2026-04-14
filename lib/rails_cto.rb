# frozen_string_literal: true

require_relative "rails_cto/version"

module RailsCTO
  autoload :CLI,       "rails_cto/cli"
  autoload :Installer, "rails_cto/installer"
  autoload :Doctor,    "rails_cto/doctor"

  def self.templates_root
    File.expand_path("rails_cto/templates", __dir__)
  end
end
