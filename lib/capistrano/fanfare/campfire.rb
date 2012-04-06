require 'capistrano'

module Capistrano::Fanfare::Campfire
  def self.load_into(configuration)
    configuration.load do
      begin
        require 'campy'

      rescue LoadError => error
        raise "campy gem could not be loaded: (#{error.message}). " +
          "Please ensure it is in your Gemfile."
      end

      set(:campfire_yaml_file) do
        yaml_file = File.expand_path(ENV['CAMPFIRE_YAML_FILE'] || '~/.campfire.yml')

        if !File.exists?(yaml_file)
          raise "File '#{yaml_file}' does not exist with campfire configuration."
        end

        yaml_file
      end

      set(:campfire_options)  { YAML.load_file(campfire_yaml_file) }
      set(:campfire_room)     { Campy::Room.new(campfire_options) }

      set(:campfire_pre_msg) do
        [ ENV['USER'],
          %{is starting a deploy of},
          application,
          %{from},
          branch,
          %{to},
          deploy_env
        ].join(' ')
      end

      set(:campfire_success_msg) do
        "Deployment started by #{ENV['USER']} succeeded."
      end

      set(:campfire_fail_msg) do
        "Deployment started by #{ENV['USER']} failed, so attempting to roll back."
      end

      set(:campfire_web_disable_msg) do
        reason = ENV['REASON'] ? %{"#{ENV['REASON']}"} : "No reason given"
        msg = [
          "#{ENV['USER']} is bringing #{application}_#{deploy_env}",
          "down into maintenance mode (#{reason})."
        ]
        msg.join(' ')
      end

      set(:campfire_web_enable_msg) do
        "#{ENV['USER']} is bringing #{application}_#{deploy_env} back from maintenance mode."
      end

      set :campfire_success_play, "pushit"
      set :campfire_fail_play,    "trombone"

      # fail fast if campfire options cannot be loaded
      on :load do
        fetch(:campfire_options)
      end


      # ========================================================================
      # These are helper methods that will be available to your recipes.
      # ========================================================================

      def deploy_env_formatted
        if deploy_env.to_s.downcase.start_with? 'prod'
          "**#{deploy_env.to_s.upcase}**"
        else
          deploy_env.to_s.downcase
        end
      end

      def speak(msg)
        if dry_run
          puts "[campfire.speak]: #{msg}"
        else
          campfire_room.speak msg
        end
      end

      def play(clip)
        if dry_run
          puts "[campfire.play]: #{clip}"
        else
          campfire_room.play clip
        end
      end


      # ========================================================================
      # These are the tasks that are available to help with deploying web apps.
      # You can have cap give you a summary of them with `cap -T'.
      # ========================================================================

      namespace :campfire do
        desc <<-DESC
          [internal] Posts a message in Campfire before a deploy has started.
        DESC
        task :pre_deploy do
          @deploy_start_time = Time.now
          speak fetch(:campfire_pre_msg)
        end

        desc <<-DESC
          [internal] Posts a message and plays a clip after a successful
          deployment.
        DESC
        task :successful_deploy do
          elapsed = @deploy_start_time ? Time.now - @deploy_start_time : 0

          speak "#{fetch(:campfire_success_msg)} (#{elapsed} seconds)"
          play fetch(:campfire_success_play)
        end

        desc <<-DESC
          [internal] Posts a message and plays a clip after a failed
          deployment.
        DESC
        task :rollback_deploy do
          speak fetch(:campfire_fail_msg)
          play fetch(:campfire_fail_play)
        end

        desc <<-DESC
          [internal] Posts a message in Campfire when the app is being brought down.
        DESC
        task :web_disable do
          speak fetch(:campfire_web_disable_msg)
        end

        desc <<-DESC
          [internal] Posts a message in Campfire when the app is being brought up.
        DESC
        task :web_enable do
          speak fetch(:campfire_web_enable_msg)
        end
      end

      unless ENV['QUIET'].to_i > 0
        before  "deploy", "campfire:pre_deploy"
        after   "deploy", "campfire:successful_deploy"
        after   "deploy:migrations", "campfire:successful_deploy"
        before  "deploy:web:disable", "campfire:web_disable"
        before  "deploy:web:enable", "campfire:web_enable"
      end

      before 'deploy:rollback', 'campfire:rollback_deploy'
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Campfire.load_into(Capistrano::Configuration.instance)
end
