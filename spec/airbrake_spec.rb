require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/airbrake'

describe Capistrano::Fanfare::Airbrake do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::Airbrake.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
    @orig_config = Capistrano::Configuration.instance
    Capistrano::Configuration.instance = @config
  end

  after do
    Capistrano::Configuration.instance = @orig_config
  end

  describe "for namespace :airbrake" do
    it "create a :deploy task" do
      @config.must_have_task "airbrake:deploy"
    end
  end
end
