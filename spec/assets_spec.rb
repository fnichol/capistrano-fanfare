require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/assets'

describe Capistrano::Fanfare::Assets do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::Assets.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
    # @orig_config = Capistrano::Configuration.instance
    # Capistrano::Configuration.instance = @config
  end

  after do
    # Capistrano::Configuration.instance = @orig_config
  end

  describe "for namespace :deploy" do
    it "creates a deploy:assets:symlink task" do
      @config.must_have_task "deploy:assets:symlink"
    end

    it "creates a deploy:assets:precompile task" do
      @config.must_have_task "deploy:assets:precompile"
    end

    it "creates a deploy:assets:clean task" do
      @config.must_have_task "deploy:assets:clean"
    end
  end
end
