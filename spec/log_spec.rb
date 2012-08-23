require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/log'

describe Capistrano::Fanfare::Log do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::Log.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
  end

  describe "for variables" do
    it "sets :tail_cmd to 'tail'" do
      @config.fetch(:tail_cmd).must_equal "tail"
    end
  end

  describe "for namespace :log" do
    before do
      @config.set :tail_cmd,      "/usr/bin/tail"
      @config.set :current_path,  "/my/path"
    end

    describe "task :tail" do
      it "tails a log file based on :rails_env variable" do
        @config.set :rails_env, "uat"
        @config.find_and_execute_task("log:tail")

        @config.must_have_streamed "/usr/bin/tail -f /my/path/log/uat.log"
      end

      it "tails a log file based on :rack_env variable" do
        @config.set :rack_env, "staging"
        @config.find_and_execute_task("log:tail")

        @config.must_have_streamed "/usr/bin/tail -f /my/path/log/staging.log"
      end

      it "tails the production log file if :rails_env and :rack_env does not exist" do
        @config.find_and_execute_task("log:tail")

        @config.must_have_streamed "/usr/bin/tail -f /my/path/log/production.log"
      end
    end
  end
end
