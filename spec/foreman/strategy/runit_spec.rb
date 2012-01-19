require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/foreman/strategy/runit'

describe Capistrano::Fanfare::Foreman::Strategy::Runit do
  before do
    @config = Capistrano::Configuration.new
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
  end

  let(:strategy) { Capistrano::Fanfare::Foreman::Strategy::Runit.new(@config) }

  it "#export generates runit services from the Procfile" do
    @config.set :current_release, "/srv/fooapp/releases/thisone"
    @config.set :foreman_cmd, "bin/foreman"
    @config.set :shared_path, "/srv/fooapp/shared"
    @config.set :runit_sv_path, "/srv/fooapp/shared/sv"
    @config.set :runit_app_name, "fooapp_production"
    @config.set :user, "deploy"
    strategy.export

    @config.must_have_run [
      "cd /srv/fooapp/releases/thisone &&",
      "if [ -f Procfile ] ; then",
      "mkdir -p /srv/fooapp/shared/sv &&",
      "bin/foreman export runit /srv/fooapp/shared/sv",
      "--app=fooapp_production --log=/srv/fooapp/shared/log",
      "--user=deploy ; else",
      "echo '>>>> A Procfile must exist in this project.' && exit 10 ; fi"
    ].join(' ')
  end

  it "#register symlinks services in :runit_sv_path to :runit_service_path" do
    @config.set :runit_sv_path, "/apps/foo/shared/sv"
    @config.set :runit_service_path, "/home/foouser/service"
    strategy.register

    @config.must_have_run "ln -snf /apps/foo/shared/sv/* /home/foouser/service/"
  end

  describe "#start" do
    it "starts all services without arguments" do
      @config.set :runit_service_path, "/home/foouser/service"
      @config.set :runit_app_name, "wuzzle_production"
      strategy.start

      @config.must_have_run "sv start /home/foouser/service/wuzzle_production-*"
    end
  end

  describe "#stop" do
    it "stops all services without arguments" do
      @config.set :runit_service_path, "/home/foouser/service"
      @config.set :runit_app_name, "wuzzle_production"
      strategy.stop

      @config.must_have_run "sv stop /home/foouser/service/wuzzle_production-*"
    end
  end

  describe "#restart" do
    it "restarts all services without arguments" do
      @config.set :runit_service_path, "/home/foouser/service"
      @config.set :runit_app_name, "wuzzle_production"
      strategy.restart

      @config.must_have_run "sv restart /home/foouser/service/wuzzle_production-*"
    end
  end

  describe "#ps" do
    it "returns all service process statuses" do
      @config.set :runit_service_path, "/home/foouser/service"
      @config.set :runit_app_name, "wuzzle_production"
      strategy.ps

      @config.must_have_run "sv status /home/foouser/service/wuzzle_production-*"
    end
  end
end
