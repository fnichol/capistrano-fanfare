require 'capistrano'

##
# Based on the wicked awesome code from AF83 info capistrano recipe:
# https://github.com/AF83/capistrano-af83/blob/master/lib/capistrano/af83/info.rb

module Capistrano::Fanfare::Info
  def self.load_into(configuration)
    configuration.load do
      set :info_variables, [ :application, :repository, :branch, :deploy_env,
        :user, :deploy_to, :rails_env ]


      # =========================================================================
      # These are the tasks that are available to help with deploying web apps,
      # and specifically, Rails applications. You can have cap give you a summary
      # of them with `cap -T'.
      # =========================================================================

      desc <<-DESC
      DESC
      task :info, :roles => :app, :except => { :no_release => true } do
        logger.important "Configuration:"
        fetch(:info_variables, []).each do |var|
          logger.important %{* #{var}: "#{fetch(var, "<undefined>")}"}
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Info.load_into(Capistrano::Configuration.instance)
end
