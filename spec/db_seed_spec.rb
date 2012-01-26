require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/db_seed'

describe Capistrano::Fanfare::DbSeed do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::DbSeed.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
  end

  describe "for namespace :db" do
    describe "for :seed task" do
      it "runs the db:seed rake task" do
        @config.set :current_path, "/a/current"
        @config.set :rake, "bin/rake"
        @config.find_and_execute_task("db:seed")

        @config.must_have_run(
          "cd /a/current && bin/rake RAILS_ENV=production db:seed")
      end
    end
  end
end
