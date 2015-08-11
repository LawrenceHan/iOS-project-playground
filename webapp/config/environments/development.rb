Carevoice::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # config.middleware.use ExceptionNotification::Rack,
  #   :email => {
  #     :email_prefix => "[carevoice-development] ",
  #     :sender_address => %{"Notifier" <notifier@thecarevoice.com>},
  #     :exception_recipients => %w{dev.carevoice@ekohe.com},
  #     :email_format => :html
  #   }



  # use mailtrap here, http://rubygems.org/gems/mailtrap & https://github.com/mmower/mailtrap
  # run: mailtrap run 
  # config.action_mailer.smtp_settings = {
  #  :address =>              'localhost',
  #  :port =>                 2525
  # }
  
  config.i18n.fallbacks = true
  config.i18n.available_locales = ['zh-CN', :en]
  
end
