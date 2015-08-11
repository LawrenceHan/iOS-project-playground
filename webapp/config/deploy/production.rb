set :branch, 'master'
set (:deploy_to)  { "/var/www/#{application}" }
set :rvm_ruby_string, "2.0@#{application}"

role :web, "hk.ekohe.com"
role :app, "hk.ekohe.com"
role :db,  "hk.ekohe.com", :primary => true

# This hook should run in all china server
after 'configure', 'cope_cegedim_xlsx'
task :cope_cegedim_xlsx do
  run "mkdir -p #{current_release}/tmp/cegedim"
  run "cp -r #{shared_path}/tmp/cegedim #{current_release}/tmp"
end

after 'deploy:symlink', 'link_microsites'
task :link_microsites do
  run "ln -s /var/www/carevoice/shared/microsites /var/www/carevoice/current/public/microsites"
end

namespace :deploy do
  [:start, :stop, :restart].each do |action|
    task action do
      run "sudo monit -g #{application} #{action} all"
    end
  end
end

def our_rake(task)
  run "cd #{current_release}; sudo -u www-data bash -c 'source /usr/local/lib/rvm && rvm #{rvm_ruby_string} && RAILS_ENV=production bundle exec rake #{task}'"
end

