require 'capistrano'

module Capistrano::Fanfare::Log
  def self.load_into(configuration)
    configuration.load do
      set :tail_cmd, "tail"

      namespace :log do
        desc <<-DESC
          Tails the deployed application log.You can set the rails \
          environment by setting the :rails_env variable. The defaults are:

              set :rails_env, "production"
              set :tail_cmd,  "tail"
        DESC
        task :tail, :role => :app, :except => { :no_release => true } do
          rack_env = fetch(:rails_env, nil) || fetch(:rack_env, nil) || "production"

          stream("#{tail_cmd} -f #{current_path}/log/#{rack_env}.log")
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Log.load_into(Capistrano::Configuration.instance)
end
