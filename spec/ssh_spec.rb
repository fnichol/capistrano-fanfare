require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/ssh'

describe Capistrano::Fanfare::Ssh do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::Ssh.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
    @orig_config = Capistrano::Configuration.instance
    Capistrano::Configuration.instance = @config
  end

  after do
    Capistrano::Configuration.instance = @orig_config
  end

  it "creates an ssh task" do
    @config.must_have_task "ssh"
  end
end
