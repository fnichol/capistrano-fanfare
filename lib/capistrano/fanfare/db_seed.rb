require 'capistrano'

module Capistrano::Fanfare::DbSeed
  def self.load_into(configuration)
    configuration.load do

      # =========================================================================
      # These are the tasks that are available to help with deploying web apps.
      # You can have cap give you a summary of them with `cap -T'.
      # =========================================================================

      namespace :db do

        desc <<-DESC
          Runs the rake db:seed task.

          You can set the rails environment and full path to rake by setting some \
          overriding variables. The defaults are:

            set :rake,      "rake"
            set :rails_env, "production"

          [WARNING] This command is probably not safe to run multiple times.
        DESC
        task :seed, :roles => :db, :only => { :primary => true } do
          rails_env = fetch(:rails_env, nil) || fetch(:rack_env, nil) || "production"

          run %{cd #{current_path} && #{rake} RAILS_ENV=#{rails_env} db:seed}
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::DbSeed.load_into(Capistrano::Configuration.instance)
end
