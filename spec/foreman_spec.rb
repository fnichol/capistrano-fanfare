require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/foreman'

describe Capistrano::Fanfare::Foreman do
  before do
    @config = Capistrano::Configuration.new
    @config.load "deploy"
    Capistrano::Fanfare::Foreman.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
  end

  describe "for variables" do
    it "sets :local_procfile to 'Procfile'" do
      @config.fetch(:local_procfile).must_equal "Procfile"
    end

    it "sets :user_home to the capistrano user's home directory" do
      @config.captures_responses["echo $HOME"] = "/u/home/fooguy\n"

      @config.fetch(:user_home).must_equal "/u/home/fooguy"
    end

    it "sets :foreman_cmd to 'foreman'" do
      @config.fetch(:foreman_cmd).must_equal "foreman"
    end

    it "sets :foreman_export_via to :runit" do
      @config.fetch(:foreman_export_via).must_equal :runit
    end

    it "sets :foreman_strategy to an Runit strategy" do
      @config.fetch(:foreman_strategy).class.
        must_equal Capistrano::Fanfare::Foreman::Strategy::Runit
    end

    it "sets :runit_service_path to :user_home/service" do
      @config.set :user_home, "/home/app"

      @config.fetch(:runit_service_path).must_equal "/home/app/service"
    end

    it "sets :runit_app_name to a combination of :application and :deploy_env" do
      @config.set :application, "barness"
      @config.set :deploy_env, "production"

      @config.fetch(:runit_app_name).must_equal "barness_production"
    end

    it "sets :runit_sv_path to shared_path/sv" do
      @config.set :shared_path, "/srv/wakka/shared"

      @config.fetch(:runit_sv_path).must_equal "/srv/wakka/shared/sv"
    end
  end

  describe "for namespace :foreman" do
    let(:strategy)  { MiniTest::Mock.new }

    before do
      @config.set :foreman_strategy, strategy
    end

    describe "task :cp_env" do
      it "copies env file from shared_path into current_release as .env" do
        @config.set :shared_path, "/tmp/app/shared"
        @config.set :current_release, "/tmp/app/releases/blah"
        @config.find_and_execute_task("foreman:cp_env")

        @config.must_have_run "cp /tmp/app/shared/env /tmp/app/releases/blah/.env"
      end

      it "gets called after deploy:finalize_update task" do
        @config.must_have_callback_after "deploy:finalize_update", "foreman:cp_env"
      end
    end

    describe "task :run_cmd" do
      before do
        ENV['_FOREMAN_COMMAND'] = ENV['COMMAND']
        ENV['COMMAND'] = "rake db:migrate"
      end

      after do
        ENV['COMMAND'] = ENV.delete('_FOREMAN_COMMAND')
      end

      it "runs a command in a foreman environment context" do
        @config.set :current_path, "/apps/fuyou/current"
        @config.set :foreman_cmd, "bin/foreman"
        @config.find_and_execute_task("foreman:run_cmd")

        @config.must_have_run [
          "cd /apps/fuyou/current &&",
          "bin/foreman run 'rake db:migrate'"
        ].join(' ')
      end

      it "raises an exception when ENV['COMMAND'] is not found" do
        ENV.delete('COMMAND')
        proc { @config.find_and_execute_task("foreman:run_cmd") }.
          must_raise RuntimeError
      end
    end

    describe "task :export" do
      it "delegates to forman_strategy.export" do
        strategy.expect :export, true
        @config.find_and_execute_task("foreman:export")

        strategy.verify
      end

      it "gets called after deploy:update_code task" do
        @config.must_have_callback_after "deploy:update_code", "foreman:export"
      end
    end

    describe "task :register" do
      it "delegates to forman_strategy.register" do
        strategy.expect :register, true
        @config.find_and_execute_task("foreman:register")

        strategy.verify
      end

      it "gets called before deploy:start task" do
        @config.must_have_callback_before "deploy:start", "foreman:register"
      end

      it "gets called before deploy:restart task" do
        @config.must_have_callback_before "deploy:restart", "foreman:register"
      end
    end

    describe "task :start" do
      it "delegates to forman_strategy.start" do
        strategy.expect :start, true
        @config.find_and_execute_task("foreman:start")

        strategy.verify
      end

      it "calls foreman:start task after deploy:start" do
        @config.must_have_callback_after "deploy:start", "foreman:start"
      end
    end

    describe "task :stop" do
      it "delegates to forman_strategy.stop" do
        strategy.expect :stop, true
        @config.find_and_execute_task("foreman:stop")

        strategy.verify
      end

      it "calls foreman:stop task after deploy:stop" do
        @config.must_have_callback_after "deploy:stop", "foreman:stop"
      end
    end

    describe "task :restart" do
      it "delegates to forman_strategy.restart" do
        strategy.expect :restart, true
        @config.find_and_execute_task("foreman:restart")

        strategy.verify
      end

      it "calls foreman:restart task after deploy:restart" do
        @config.must_have_callback_after "deploy:restart", "foreman:restart"
      end
    end

    describe "task :ps" do
      it "delegates to forman_strategy.ps" do
        strategy.expect :ps, true
        @config.find_and_execute_task("foreman:ps")

        strategy.verify
      end
    end

    describe "dynamic tasks" do
      before do
        ENV['PROCFILE'] =
          File.expand_path(File.join(File.dirname(__FILE__), %w{fixtures Procfile}))
        @config = Capistrano::Configuration.new
        @config.load "deploy"
        Capistrano::Fanfare::Foreman.load_into(@config)
        @config.extend(MiniTest::Capistrano::ConfigurationExtension)
        @config.set :foreman_strategy, strategy
      end

      after do
        ENV.delete('PROCFILE')
      end

      describe "for namespace :start" do
        it "creates a task for each Procfile entry (on client side copy)" do
          @config.must_have_task "foreman:start:web"
          @config.must_have_task "foreman:start:job"
        end

        it "task :web delegates to foreman_strategy.start" do
          strategy.expect :start, true, ["web"]
          @config.find_and_execute_task("foreman:start:web")

          strategy.verify
        end
      end

      describe "for namespace :stop" do
        it "creates a task for each Procfile entry (on client side copy)" do
          @config.must_have_task "foreman:stop:web"
          @config.must_have_task "foreman:stop:job"
        end

        it "task :web delegates to foreman_strategy.stop" do
          strategy.expect :stop, true, ["web"]
          @config.find_and_execute_task("foreman:stop:web")

          strategy.verify
        end
      end

      describe "for namespace :restart" do
        it "creates a task for each Procfile entry (on client side copy)" do
          @config.must_have_task "foreman:restart:web"
          @config.must_have_task "foreman:restart:job"
        end

        it "task :web delegates to foreman_strategy.restart" do
          strategy.expect :restart, true, ["web"]
          @config.find_and_execute_task("foreman:restart:web")

          strategy.verify
        end
      end
    end
  end

  describe "task :frun" do
    it "delegates to foreman:run_cmd task" do
      @config.load do
        def methods_called ; @methods_called ||= [] ; end

        namespace :foreman do
          task(:run_cmd) { methods_called << "foreman:run_cmd" }
        end
      end
      @config.find_and_execute_task("frun")

      @config.methods_called.must_equal ["foreman:run_cmd"]
    end
  end
end
