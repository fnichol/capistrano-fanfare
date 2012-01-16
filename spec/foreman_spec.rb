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

  describe "for namespace :foreman" do
    describe "task :cp_env" do
      it "copies env file from shared_path into current_release as .env" do
        @config.set :shared_path, "/tmp/app/shared"
        @config.set :current_release, "/tmp/app/releases/blah"
        @config.find_and_execute_task("foreman:cp_env")

        @config.must_have_run "cp /tmp/app/shared/env /tmp/app/releases/blah/.env"
      end

      it "gets called after deploy:updated_code task" do
        @config.must_have_callback_after "deploy:update_code", "foreman:cp_env"
      end
    end
  end
end
