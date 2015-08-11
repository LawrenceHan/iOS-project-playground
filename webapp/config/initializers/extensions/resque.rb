require 'resque/server'

Resque.redis.namespace = "carevoice_#{Rails.env}"
if File.exist?(config_file = Rails.root.join('config', 'schedule', "#{APP_CONFIG[:node]}.yml"))
  Resque.schedule = YAML.load_file(config_file)
end

# Config basic auth account in config/app_config.yml
Resque::Server.use(Rack::Auth::Basic) do |user, password|
  user == APP_CONFIG[:resque][:basic_auth][:username] and password == APP_CONFIG[:resque][:basic_auth][:password]
end
