require 'capistrano'
require 'capistrano/fanfare/foreman/strategy'

begin
  require 'foreman/procfile'

rescue LoadError => error
  raise "Foreman gem could not be loaded: (#{error.message}). " +
    "Please ensure it is in your Gemfile."
end

module Capistrano::Fanfare::Foreman
  def self.load_into(configuration)
    configuration.load do
      set(:local_procfile)      { ENV['PROCFILE'] || "Procfile" }
      set(:user_home)           { capture("echo $HOME").chomp }

      set :foreman_cmd,         "foreman"
      set(:rake)                { "#{foreman_cmd} run rake" }
      set :foreman_export_via,  :runit

      set(:foreman_strategy) do
        Capistrano::Fanfare::Foreman::Strategy.new(foreman_export_via, self)
      end

      set(:runit_app_name)      { "#{application}_#{deploy_env}" }
      set(:runit_sv_path)       { "#{shared_path}/sv" }
      set(:runit_service_path)  { "#{user_home}/service" }

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

        desc <<-DESC
          [internal]
        DESC
        task :run_cmd, :roles => :app, :except => { :no_release => true } do
          command = ENV['COMMAND'] || ""
          raise "Please specify a command to execute via the COMMAND " +
            "environment variable" if command.empty?

          run "cd #{current_path} && #{foreman_cmd} run '#{command}'"
        end

        desc <<-DESC
          blah
        DESC
        task :export, :roles => :app, :except => { :no_release => true } do
          foreman_strategy.export
        end

        desc <<-DESC
          [internal]
        DESC
        task :register, :roles => :app, :except => { :no_release => true } do
          foreman_strategy.register
        end

        namespace :start do
          desc <<-DESC
            flaw
          DESC
          task :default, :roles => :app, :except => { :no_release => true } do
            foreman_strategy.start
          end
        end

        namespace :stop do
          desc <<-DESC
            flaw
          DESC
          task :default, :roles => :app, :except => { :no_release => true } do
            foreman_strategy.stop
          end
        end

        namespace :restart do
          desc <<-DESC
            flaw
          DESC
          task :default, :roles => :app, :except => { :no_release => true } do
            foreman_strategy.restart
          end
        end

        desc <<-DESC
          Procs
        DESC
        task :ps, :roles => :app, :except => { :no_release => true } do
          foreman_strategy.ps
        end

        if File.exists?(fetch(:local_procfile))
          def procfile
            @procfile ||= Foreman::Procfile.new(fetch(:local_procfile))
          end

          namespace :start do
            procfile.entries.each do |entry|
              send :desc, <<-DESC
                Starts #{entry.name} processes managed by the Procfile.
              DESC
              send :task, entry.name, :roles => :app, :except => { :no_release => true } do
                foreman_strategy.start(entry.name)
              end
            end
          end

          namespace :stop do
            procfile.entries.each do |entry|
              send :desc, <<-DESC
                Stops #{entry.name} processes managed by the Procfile.
              DESC
              send :task, entry.name, :roles => :app, :except => { :no_release => true } do
                foreman_strategy.stop(entry.name)
              end
            end
          end

          namespace :restart do
            procfile.entries.each do |entry|
              send :desc, <<-DESC
                Restarts #{entry.name} processes managed by the Procfile.
              DESC
              send :task, entry.name, :roles => :app, :except => { :no_release => true } do
                foreman_strategy.restart(entry.name)
              end
            end
          end
        end
      end

      desc <<-DESC
        Runnings
      DESC
      task :frun, :roles => :app, :except => { :no_release => true } do
        foreman.run_cmd
      end

      after   "deploy:finalize_update", "foreman:cp_env"
      after   "deploy:update_code",     "foreman:export"
      before  "deploy:start",           "foreman:register"
      after   "deploy:start",           "foreman:start"
      before  "deploy:restart",         "foreman:register"
      after   "deploy:restart",         "foreman:restart"
      after   "deploy:stop",            "foreman:stop"
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Foreman.load_into(Capistrano::Configuration.instance)
end
