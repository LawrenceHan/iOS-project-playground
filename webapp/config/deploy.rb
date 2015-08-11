set :stages, %w(production staging stagingindia tcv_staging tcv_production)
set :default_stage, "staging"
require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'rvm/capistrano'
ssh_options[:forward_agent] = true
ssh_options[:keepalive] = true
set :repository,  "git@git.ekohe.com:/carevoice.web.git"
set :rvm_type, :system
set :scm, :git
set :application, 'carevoice'

set :shared_children, %w(public/system log tmp/pids tmp/cache) # add tmp/cache for asset pipeline
set :rake,      "bundle exec rake"

set :use_sudo, false
# set :deploy_via, :remote_cache
set :deploy_to, "/var/www/#{application}"

task :configure, :roles => :web do
  run "ln -s #{shared_path}/config/database.yml #{current_release}/config/database.yml"
  run "ln -s #{shared_path}/config/app_config.yml #{current_release}/config/app_config.yml"
  run "ln -s #{shared_path}/config/google-drive.p12 #{current_release}/config/google-drive.p12"
  run "ln -s #{shared_path}/config/certs/apn_production.pem #{current_release}/config/certs/apn_production.pem"
end

before 'deploy:assets:precompile', :configure
after 'deploy:assets:precompile', 'deploy:assets:fancybox_fix'
after 'deploy:restart', 'deploy:cleanup'
after 'deploy:restart', 'deploy:migrate'

after 'deploy:setup', 'deploy:custom_setup'

namespace :deploy do
  namespace :assets do
    task :fancybox_fix do
      our_rake "fancybox:assets"
    end
  end

  task :migrate do
    our_rake 'db:migrate'
  end

  task :custom_setup do
    run "mkdir #{shared_path}/tmp/socks"
  end
end

def run_interactively(command, server=nil)
  server ||= find_servers_for_task(current_task).first
  exec %Q(ssh #{server.host} -t 'cd #{current_path} && #{command}')
end

desc 'Open the production rails console on the server'
task :console, :roles => :app do
  run_interactively %[
    source /usr/local/lib/rvm;
    rvm use #{rvm_ruby_string};
    bin/rails console #{rails_env} #{ENV['ARGS']};
  ]
end


task :log, :roles => :app do
  run_interactively %[tail -f log/*.log]
end

namespace :deploy do
  namespace :assets do
    task :update_asset_mtimes, :roles => lambda { assets_role }, :except => { :no_release => true } do
    end

    task :clean_expired, :roles => lambda { assets_role }, :except => { :no_release => true } do
      run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake assets:clean"
    end
  end
end
