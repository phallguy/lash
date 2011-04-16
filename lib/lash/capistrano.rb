Capistrano::Configuration.instance.load do
  namespace :deploy do
    task :lash, :roles => [:app], :except => { :no_release => true } do
      
      old_rake = fetch(:old_rake, rake)
      
      run "#{try_sudo} chmod g+w #{release_path}/tmp"
      run "cd #{release_path} && #{try_sudo} #{old_rake} RAILS_ENV=production lash:deploy_secure"
      run "cd #{release_path} && #{rake} RAILS_ENV=production lash:deploy"
    end
    after "deploy:update_code", "deploy:lash"
  end
end
