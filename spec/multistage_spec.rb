require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/multistage'

describe Capistrano::Fanfare::Multistage do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::Multistage.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
    @orig_config = Capistrano::Configuration.instance
    Capistrano::Configuration.instance = @config
  end

  after do
    Capistrano::Configuration.instance = @orig_config
  end

  describe "for variables" do
    it "sets :stages array to staging and production" do
      @config.fetch(:stages).must_equal ["staging", "production"]
    end

    it "sets :default_stage to staging" do
      @config.fetch(:default_stage).must_equal "staging"
    end
  end

  describe "for tasks" do
    it "defines a task for each stage" do
      @config = Capistrano::Configuration.new
      @config.set :stages, %w{dev prod chickens}
      Capistrano::Fanfare::Multistage.load_into(@config)
      @config.extend(MiniTest::Capistrano::ConfigurationExtension)
      @orig_config = Capistrano::Configuration.instance
      Capistrano::Configuration.instance = @config

      @config.must_have_task :dev
      @config.must_have_task :prod
      @config.must_have_task :chickens
    end
  end
end
