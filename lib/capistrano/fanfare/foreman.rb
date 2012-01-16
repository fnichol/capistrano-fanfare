require 'capistrano'

module Capistrano::Fanfare::Foreman
  def self.load_into(configuration)
    configuration.load do
      # =========================================================================
      # These are the tasks that are available to help with deploying web apps.
      # You can have cap give you a summary of them with `cap -T'.
      # =========================================================================

      namespace :foreman do
        desc <<-DESC
          [internal] Copies env from shared path into current_path as .env
        DESC
        task :cp_env, :roles => :app, :except => { :no_release => true } do
          run "cp #{shared_path}/env #{current_release}/.env"
        end
      end

      after "deploy:update_code", "foreman:cp_env"
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Foreman.load_into(Capistrano::Configuration.instance)
end
