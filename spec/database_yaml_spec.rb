require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/database_yaml'

describe Capistrano::Fanfare::DatabaseYaml do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::DatabaseYaml.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
  end

  describe "for namespace :db" do
    describe "task :cp_database_yml" do
      it "copies config/database.yml into :release_path" do
        @config.set :shared_path, "/a/appattack/shared"
        @config.set :release_path, "/a/appattack/releases/thisone"
        @config.find_and_execute_task("db:cp_database_yml")

        @config.must_have_run [
          "mkdir -p /a/appattack/releases/thisone/config &&",
          "cp /a/appattack/shared/config/database.yml",
            "/a/appattack/releases/thisone/config/database.yml"
        ].join(' ')
      end

      it "gets called after deploy:update_code task" do
        @config.must_have_callback_after "deploy:update_code", "db:cp_database_yml"
      end
    end
  end
end
