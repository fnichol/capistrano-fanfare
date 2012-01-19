require 'capistrano'

module Capistrano::Fanfare::DatabaseYaml
  def self.load_into(configuration)
    configuration.load do
      # =========================================================================
      # These are the tasks that are available to help with deploying web apps.
      # You can have cap give you a summary of them with `cap -T'.
      # =========================================================================

      namespace :db do
        desc <<-DESC
          [internal] Copies database.yml from shared_path into release_path.
        DESC
        task :cp_database_yml, :roles => :app, :except => { :no_release => true } do
         run [
           "mkdir -p #{release_path}/config &&",
           "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"
         ].join(' ')
        end
      end

      after "deploy:update_code", "db:cp_database_yml"
    end
  end
end
