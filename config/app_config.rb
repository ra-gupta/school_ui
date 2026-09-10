# frozen_string_literal: true

require "yaml"
require "erb"
require "pathname"
require "active_support/core_ext/hash/deep_merge"
require "active_support/hash_with_indifferent_access"

# Reads config/app_config.default.yml, then config/app_config.yml on top of it.
#
# Sections merge in order — `default`, then the current environment, then the
# same two from the local file — so a change to one value does not mean
# restating the rest.
#
# Two rules:
#
#   1. The environment always wins. Every value that can come from a variable is
#      written as `ENV.fetch("NAME", fallback)`, so the committed file holds the
#      fallback and never a secret.
#
#   2. config/app_config.yml is gitignored and is where this machine's own
#      values live, instead of exporting variables into every shell. Copy
#      config/app_config.yml.example to start one.
#
# Lives in config/ rather than lib/ because config/application.rb reads it
# before the autoloader exists.
module AppConfig
  DEFAULT_FILENAME = "app_config.default.yml"
  LOCAL_FILENAME = "app_config.yml"

  class << self
    attr_writer :root, :environment

    delegate :[], :dig, :fetch, :key?, :to_h, to: :settings

    def root = @root ||= Pathname.new(File.expand_path(__dir__))

    def environment = @environment ||= (defined?(Rails) ? Rails.env.to_s : ENV.fetch("RAILS_ENV", "development"))

    def settings = @settings ||= build

    # For tests, and for anything that changes the environment underneath us.
    def reload!
      @settings = nil
      self
    end

    private

    def build
      sections(DEFAULT_FILENAME)
        .deep_merge(sections(LOCAL_FILENAME))
        .then { |merged| ActiveSupport::HashWithIndifferentAccess.new(merged).freeze }
    end

    def sections(filename)
      file = read(filename)
      (file["default"] || {}).deep_merge(file[environment] || {})
    end

    def read(filename)
      path = root.join(filename)
      return {} unless path.exist?

      # ERB first, so `ENV.fetch(...)` in the file is what lets the environment
      # win over every fallback written there.
      YAML.safe_load(ERB.new(path.read).result, aliases: true) || {}
    end
  end
end
