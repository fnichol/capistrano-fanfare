require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/defaults'
require 'capistrano/fanfare/bundler'
require 'capistrano/fanfare/foreman'

describe Capistrano::Fanfare::Defaults do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::Defaults.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
    ENV['BRANCH'] = nil
  end

  it "sets :scm to :git" do
    @config.fetch(:scm).must_equal :git
  end

  it "sets :use_sudo to false" do
    @config.fetch(:use_sudo).must_equal false
  end

  it "sets :user to 'deploy'" do
    @config.fetch(:user).must_equal "deploy"
  end

  it "sets :ssh_options to include :forward_agent => true" do
    @config.fetch(:ssh_options)[:forward_agent].must_equal true
  end

  it "sets :deploy_to to a directory containing :application and :deploy_env" do
    @config.set :application, "fizzy"
    @config.set :deploy_env,  "staging"

    @config.fetch(:deploy_to).must_equal "/srv/fizzy_staging"
  end

  describe ":branch" do
    it "sets to master by default" do
      @config.fetch(:branch).must_equal "master"
    end

    it "sets to ENV['BRANCH'] if set" do
      ENV['BRANCH'] = "tree-branch"

      @config.fetch(:branch).must_equal "tree-branch"
    end
  end

  describe ":deploy_env" do
    before do
      @config.set :stage,     "stage_env"
      @config.set :rails_env, "railsy_baby"
      @config.set :rack_env,  "rackish_dude"

      ENV['RAILS_ENV']  = "rails_env_hash"
      ENV['RACK_ENV']   = "rack_env_hash"
    end

    after do
      ENV.delete 'RAILS_ENV'
      ENV.delete 'RACK_ENV'
    end

    it "sets to :stage if it exists" do
      @config.fetch(:deploy_env).must_equal "stage_env"
    end

    it "set to :rails_env if :stage isn't present" do
      @config.unset :stage

      @config.fetch(:deploy_env).must_equal "railsy_baby"
    end

    it "set to ENV['RAILS_ENV'] if :stage and :rails_env arent't present" do
      @config.unset :stage
      @config.unset :rails_env

      @config.fetch(:deploy_env).must_equal "rails_env_hash"
    end

    it "set to :rack_env if :stage, :rails_env, and ENV['RAILS_ENV'] arent't present" do
      @config.unset :stage
      @config.unset :rails_env
      ENV.delete 'RAILS_ENV'

      @config.fetch(:deploy_env).must_equal "rackish_dude"
    end

    it "set to ENV['RACK_ENV'] if :stage, :rails_env, ENV['RAILS_ENV'], and :rack_env arent't present" do
      @config.unset :stage
      @config.unset :rails_env
      @config.unset :rack_env
      ENV.delete 'RAILS_ENV'

      @config.fetch(:deploy_env).must_equal "rack_env_hash"
    end

    it "set to 'production' as a fallback" do
      @config.unset :stage
      @config.unset :rails_env
      @config.unset :rack_env
      ENV.delete 'RAILS_ENV'
      ENV.delete 'RACK_ENV'

      @config.fetch(:deploy_env).must_equal "production"
    end
  end

  it "sets :pty = true for default_run_options" do
    @config.default_run_options[:pty].must_equal true
  end

  it "sets :os_types to a list of OSes" do
    @config.fetch(:os_types).must_equal [:darwin, :linux, :sunos, :mswin]
  end

  describe ":os_type" do
    it "set to :darwin for Mac OS" do
      @config.captures_responses["uname -s"] = "Darwin\n"

      @config.fetch(:os_type).must_equal :darwin
    end

    it "set to :linunx for Linux-based OSes" do
      @config.captures_responses["uname -s"] = "Linux\n"

      @config.fetch(:os_type).must_equal :linux
    end

    it "set to :sunos for Solaris-based OSes" do
      @config.captures_responses["uname -s"] = "SunOS\n"

      @config.fetch(:os_type).must_equal :sunos
    end
  end

  it "sets :shared_children to include tmp/sockets and tmp/sessions" do
    @config.fetch(:shared_children).
      must_equal %w{public/system log tmp/pids tmp/sockets tmp/sessions}
  end

  it "sets :rake to 'rake' if bundler recipe is loaded" do
    Capistrano::Fanfare::Bundler.load_into(@config)
    @config.trigger(:load)

    @config.fetch(:rake).must_equal "rake"
  end

  it "sets :rake to 'foreman run rake' if foreman recipe is loaded" do
    Capistrano::Fanfare::Foreman.load_into(@config)
    @config.set :foreman_cmd, "da/foreman"
    @config.trigger(:load)

    @config.fetch(:rake).must_equal "da/foreman run rake"
  end

  it "sets :rake to 'foreman run rake' if foreman and bundler recipes are loaded" do
    Capistrano::Fanfare::Foreman.load_into(@config)
    Capistrano::Fanfare::Bundler.load_into(@config)
    @config.set :foreman_cmd, "fman"
    @config.trigger(:load)

    @config.fetch(:rake).must_equal "fman run rake"
  end

  describe "for :deploy namespace" do
    describe "task :cold" do
      before do
        @config.load do
          def methods_called ; @methods_called ||= [] ; end

          namespace :deploy do
            task(:update)   { methods_called << "deploy:update" }
            task(:migrate)  { methods_called << "deploy:migrate" }
            task(:start)    { methods_called << "deploy:start" }
          end
        end
      end

      it "calls same tasks as delivered gem code" do
        @config.find_and_execute_task("deploy:cold")

        @config.methods_called.must_equal(
          ["deploy:update", "deploy:migrate", "deploy:start"])
      end

      it "calls db:seed if the task exists" do
        @config.namespace :db do
          task(:seed) { methods_called << "db:seed" }
        end
        @config.find_and_execute_task("deploy:cold")

        @config.methods_called.must_include "db:seed"
      end
    end
  end
end
