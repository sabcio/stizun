require "bundler/capistrano"

set :application, "lincomp"

set :scm, :git
set :repository, "git://github.com/psy-q/stizun.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :keep_releases, 2

set :use_sudo, false
set :deploy_to, "/home/lincomp/production"


set :db_config, "/home/lincomp/database_prod.yml"
set :stizun_config, "/home/lincomp/stizun.yml"
set :email_config, "/home/lincomp/email.yml"
set :custom_directory, "/home/lincomp/custom"

role :web, "lincomp@www.lincomp.ch"                          # Your HTTP server, Apache/etc
role :app, "lincomp@www.lincomp.ch"                          # This may be the same as your `Web` server
role :db,  "lincomp@www.lincomp.ch", :primary => true # This is where Rails migrations will run

task :link_config do
  on_rollback { run "rm #{release_path}/config/database.yml" }
  if File.exist?("rm #{release_path}/config/database.yml")
    run "rm #{release_path}/config/database.yml"
  end
  run "ln -s #{db_config} #{release_path}/config/database.yml"
  run "rm #{release_path}/config/stizun.yml"
  run "ln -s #{stizun_config} #{release_path}/config/stizun.yml"
  run "rm #{release_path}/config/email.yml"
  run "ln -s #{email_config} #{release_path}/config/email.yml"

  run "sed -i 's,config.action_mailer.perform_deliveries = false,config.action_mailer.perform_deliveries = true,' #{release_path}/config/environments/production.rb"
end

task :link_files do
    run "ln -s #{deploy_to}/#{shared_dir}/tmp/downloads #{release_path}/tmp/downloads"
    run "ln -s #{deploy_to}/#{shared_dir}/uploads #{release_path}/public/uploads"
end

task :configure_sphinx do
  run "cd #{release_path} && RAILS_ENV=production bundle exec rake ts:conf && RAILS_ENV=production bundle exec rake ts:reindex"
end

task :start_sphinx do
  run "cd #{release_path} && RAILS_ENV=production bundle exec rake ts:start"
end

task :stop_sphinx do
  run "cd #{release_path} && RAILS_ENV=production bundle exec rake ts:stop"
end

task :overwrite_custom do
  run "cd #{release_path} && rm -rf #{release_path}/custom"
  run "ln -s #{custom_directory} #{release_path}/custom"
end


namespace :deploy do
   task :restart, :roles => :app, :except => { :no_release => true } do
     #run "cd #{release_path} && RAILS_ENV='production' bundle exec rake db:migrate"
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end

end

before "deploy:assets:precompile", :link_config
after "deploy:restart", "stop_sphinx"
after "link_config", "link_files"
after "link_config", "configure_sphinx"
after "link_config", "overwrite_custom"
after "deploy:restart", "start_sphinx"
after "deploy", "deploy:cleanup"
