require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

begin
  APP_CONFIG = File.open(File.expand_path('../app_config.yml', __FILE__)) { |file| YAML.load(file) }[Rails.env].deep_symbolize_keys
rescue LoadError
  puts e.message
  puts "config/app_config.yml is not configured!"
  puts "You can copy the example from config/app_config.example.yml to get started."
end

module Carevoice
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.paths.add "app/api", glob: "**/*.rb"
    config.paths.add "app/models/validators"
    config.autoload_paths += %W(
      #{config.root}/app/api
      #{config.root}/app/api/v1
      #{config.root}/app/api/v2
      #{config.root}/app/api/helpers
      #{config.root}/app/models/validators
    )
    config.eager_load_paths += %W(
      #{config.root}/app/api
      #{config.root}/app/api/v1
      #{config.root}/app/api/v2
      #{config.root}/app/api/helpers
      #{config.root}/app/models/validators
    )

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = APP_CONFIG[:time_zone] || 'Beijing'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = (APP_CONFIG[:locale].presence || 'zh-CN').to_sym

    config.action_mailer.delivery_method = APP_CONFIG[:mailer][:delivery_method].to_sym
    config.action_mailer.default_url_options = APP_CONFIG[:mailer][:default_url_options]
    config.action_mailer.smtp_settings = APP_CONFIG[:mailer][:smtp] || {}

    config.active_record.observers = :helpful_observer

    # For PostgreSQL's full text index
    config.active_record.schema_format = :sql

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: true
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end
  end
end

I18n.enforce_available_locales = false

require 'monkey_patches/action_view/helpers/form_builder'
