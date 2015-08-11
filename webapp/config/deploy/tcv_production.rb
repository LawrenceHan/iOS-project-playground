require 'capistrano-unicorn'

# cap tcv_production deploy -s branch=feature/19-customization
set :branch, fetch(:branch, 'master')

set :deploy_to,  '/home/tcv/sites/webapp/production'
set :repository,  "git@github.com:thecarevoice/webapp.git"
set :user, 'tcv'
set :rails_env, 'production'
set :unicorn_env, 'production'
set :unicorn_rack_env, 'production'
set :unicorn_pid, "#{deploy_to}/current/tmp/pids/unicorn.pid"
set :rvm_ruby_string, '2.0.0'
set :deploy_via, :remote_cache
set :default_shell, "/bin/bash -l"

set :bundle_cmd, '/home/tcv/.rvm/bin/rvm 2.0.0 do bundle'

role :web, 'production.kangyu.co'
role :app, 'production.kangyu.co'
role :db, 'production.kangyu.co', primary: true

after 'deploy:restart', 'unicorn:restart'
after 'deploy:restart', 'deploy:resque:restart'

# This hook should run in all china server
after 'configure', 'cope_cegedim_xlsx'
task :cope_cegedim_xlsx do
  run "mkdir -p #{current_release}/tmp/cegedim"
  run "cp -r #{shared_path}/tmp/cegedim #{current_release}/tmp"
end

task :configure, :roles => :web do
  run "ln -sf #{shared_path}/tmp/socks/ #{current_release}/tmp/socks"
  run "ln -s #{shared_path}/config/database.yml #{current_release}/config/database.yml"
  run "ln -s #{shared_path}/config/app_config.yml #{current_release}/config/app_config.yml"
  run "ln -s #{shared_path}/config/certs/apn_production.pem #{current_release}/config/certs/apn_production.pem"
  run "ln -s #{shared_path}/config/newrelic.yml #{current_release}/config/newrelic.yml"
  run "ln -s #{shared_path}/config/unicorn.rb #{current_release}/config/unicorn.rb"
  run "ln -s #{shared_path}/bin/*.sh #{current_release}/bin/"
  run "ln -s #{shared_path}/bundler_gems #{current_release}/bundler"
  run "cd #{current_release}; #{bundle_cmd} install --path bundler --without development test"
end

namespace :deploy do
  namespace :resque do
    task :restart, :roles => :db do
      run "sudo monit restart carevoice_resque"
      run "sudo monit restart carevoice_resque_scheduler"
    end
  end
end

def our_rake(task)
  run "cd #{current_release}; RAILS_ENV=#{rails_env} #{bundle_cmd} exec rake #{task}"
end
