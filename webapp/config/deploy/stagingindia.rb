set :branch, 'develop'
set (:deploy_to)  { "/var/www/#{application}india" }
set :rails_env, 'stagingindia'

role :web, "hk.ekohe.com"
role :app, "hk.ekohe.com"
role :db,  "hk.ekohe.com", :primary => true

# This hook should run in all india server
after 'configure', 'cope_india_xlsx'
task :cope_india_xlsx do
  run "mkdir -p #{current_release}/tmp/india"
  run "cp -r #{shared_path}/tmp/india #{current_release}/tmp"
end

set :rvm_ruby_string, "2.0@#{application}india"
namespace :deploy do
  [:start, :stop, :restart].each do |action|
    task action do
      run "sudo monit -g #{application}india #{action} all"
    end
  end
end



def our_rake(task)
  run "cd #{current_release}; sudo -u www-data bash -c 'source /usr/local/lib/rvm && rvm #{rvm_ruby_string} && RAILS_ENV=stagingindia bundle exec rake #{task}'"
end
