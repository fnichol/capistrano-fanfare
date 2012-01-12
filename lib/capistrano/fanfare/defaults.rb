require 'capistrano'

module Capistrano::Fanfare::Defaults
  def self.load_into(configuration)
    configuration.load do
      set :scm,         :git
      set :use_sudo,    false
      set :user,        "deploy"
      set :rake,        "bundle exec rake"
      set(:branch)      { ENV['BRANCH'] ? ENV['BRANCH'] : "master" }
      set(:deploy_to)   { "/srv/#{application}_#{deploy_env}" }
      set :ssh_options, { :forward_agent => true }
      set(:os_type)     { capture("uname -s").chomp.downcase.to_sym }

      default_run_options[:pty] = true

      ##
      # Determines deployment environment or run mode to help database naming,
      # deploy directories, etc.
      #
      # Thanks to capistrano-recipies for the great idea:
      # https://github.com/webficient/capistrano-recipes
      set(:deploy_env)  {
        if exists?(:stage)
          stage
        elsif exists?(:rails_env)
          rails_env
        elsif ENV['RAILS_ENV']
          ENV['RAILS_ENV']
        elsif exists?(:rack_env)
          rack_env
        elsif ENV['RACK_ENV']
          ENV['RACK_ENV']
        else
          "production"
        end
      }
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Defaults.load_into(Capistrano::Configuration.instance)
end
