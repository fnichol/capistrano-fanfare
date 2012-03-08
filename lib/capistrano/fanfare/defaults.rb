require 'capistrano'

module Capistrano::Fanfare::Defaults
  def self.load_into(configuration)
    configuration.load do
      set :scm,         :git
      set :use_sudo,    false
      set :user,        "deploy"
      set(:branch)      { ENV['BRANCH'] ? ENV['BRANCH'] : "master" }
      set(:deploy_to)   { "/srv/#{application}_#{deploy_env}" }
      set :ssh_options, { :forward_agent => true }
      set :os_types,    [:darwin, :linux, :sunos, :mswin]
      set(:os_type)     { capture("uname -s").chomp.downcase.to_sym }

      set :shared_children, %w{public/system log tmp/pids tmp/sockets tmp/sessions}

      default_run_options[:pty] = true

      on :load do
        if exists?(:foreman_cmd)        # foreman recipe has been loaded
          set :rake, "#{fetch(:foreman_cmd)} run rake"
        elsif exists?(:bundle_shebang)  # bundler recipe has been loaded
          set :rake, "rake"
        end
      end

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

      # =========================================================================
      # These are the tasks that are available to help with deploying web apps.
      # You can have cap give you a summary of them with `cap -T'.
      # =========================================================================

      namespace :deploy do
        desc <<-DESC
          Deploys and starts a `cold' application. This is useful if you have not \
          deployed your application before, or if your application is (for some \
          other reason) not currently running. It will deploy the code, run any \
          pending migrations, and then instead of invoking `deploy:restart', it \
          will invoke `deploy:start' to fire up the application servers.

          [NOTE] This overides the capistrano default by calling the "db:seed" \
          task, if it is defined.
        DESC
        task :cold do
          update
          migrate
          db.seed if respond_to?(:db) && db.respond_to?(:seed)
          start
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Defaults.load_into(Capistrano::Configuration.instance)
end
