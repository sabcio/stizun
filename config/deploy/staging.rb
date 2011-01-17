set :application, "lincomp"

set :scm, :git
set :repository, "git://github.com/psy-q/stizun.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :keep_releases, 2 

set :use_sudo, false
set :deploy_to, "/home/web/test.lincomp.org/test"


set :db_config, "/home/web/test.lincomp.org/database_test.yml"


role :web, "lincomp@test.lincomp.org"                          # Your HTTP server, Apache/etc
role :app, "lincomp@test.lincomp.org"                          # This may be the same as your `Web` server
role :db,  "lincomp@test.lincomp.org", :primary => true # This is where Rails migrations will run

task :link_config do
  on_rollback { run "rm #{release_path}/config/database.yml" }
  run "rm #{release_path}/config/database.yml"
  run "ln -s #{db_config} #{release_path}/config/database.yml"
  run "rm -r #{release_path}/test"
  run "ln -s #{release_path}/public #{release_path}/test"
end

task :install_gems do
  run "cd #{release_path} && RAILS_ENV=production bundle install --deployment --without cucumber development"
end

task :configure_sphinx do
  run "cd #{release_path} && RAILS_ENV=production bundle exec rake ts:conf && RAILS_ENV=production bundle exec rake ts:reindex"
end

task :restart_sphinx do
  run "cd #{release_path} && RAILS_ENV=production bundle exec rake ts:restart"
end


namespace :deploy do
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end

   task :after_deploy do
     cleanup
   end 
end

after "deploy:symlink", :link_config
after "link_config", "install_gems"
after "install_gems", "configure_sphinx"
after "configure_sphinx", "restart_sphinx"
