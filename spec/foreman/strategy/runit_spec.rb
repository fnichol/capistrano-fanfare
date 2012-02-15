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
    @config.set :runit_service_path, "/home/foouser/service"
    @config.set :user, "deploy"
    strategy.export

    @config.must_have_run [
      "svp=/srv/fooapp/shared/sv &&",
      "cd /srv/fooapp/releases/thisone &&",
      "if [ -f Procfile ] ; then",
        "rm -rf ${svp}-pre &&",
        "mkdir -p ${svp}-pre &&",
        "bin/foreman export runit ${svp}-pre",
          "--app=fooapp_production --log=/srv/fooapp/shared/log",
          "--user=deploy >/dev/null &&",
        "egrep -lr ${svp}-pre ${svp}-pre | (xargs",
        "sed -i \"s|${svp}-pre|${svp}|g\" 2>/dev/null || true) &&",
        "(cd ${svp} ; find . -path '*/supervise' -type d -prune -o -type f | grep -v 'supervise$' | sort | xargs openssl sha) > /tmp/sv-dir-$$ &&",
        "(cd ${svp}-pre ; find . -path '*/supervise' -type d -prune -o -type f | grep -v 'supervise$' | sort | xargs openssl sha) > /tmp/sv-pre-dir-$$ &&",
        "if diff -q /tmp/sv-dir-$$ /tmp/sv-pre-dir-$$ >/dev/null ; then",
          "echo '-----> Foreman export atrifacts are identical' &&",
          "rm -rf ${svp}-pre",
        "; else",
            "echo '-----> Updated Foreman export artifacts detected' &&",
            "echo '-----> Stoping processes' &&",
            "rm -f /home/foouser/service/fooapp_production-* &&",
            "echo '-----> Installing updated Foreman export artifacts' &&",
            "rm -rf ${svp} && mv ${svp}-pre ${svp} &&",
            "touch ${svp}/.symlink_boot",
        "; fi &&",
        "echo '-----> Cleaning up' &&",
        "rm -f /tmp/sv-{dir,pre-dir}-$$",
      "; else",
        "echo '>>>> A Procfile must exist in this project.' && exit 10",
      "; fi"
    ].join(' ')
  end

  describe "#register" do
    it "symlinks services in :runit_sv_path to :runit_service_path" do
      @config.set :runit_sv_path, "/apps/foo/shared/sv"
      @config.set :runit_service_path, "/home/foouser/service"
      @config.captures_responses["if [ -f /apps/foo/shared/sv/.symlink_boot ] ; then echo true ; else echo false ; fi"] = "true\n"
      strategy.register

      @config.must_have_run [
        "ln -snf /apps/foo/shared/sv/* /home/foouser/service/",
        "rm -f /apps/foo/shared/sv/.symlink_boot"
      ].join(' && ')
    end

    describe "with a symlink_boot" do
      before do
        @config.set :runit_sv_path, "/apps/foo/shared/sv"
        @config.set :runit_service_path, "/home/foouser/service"
        @config.after "deploy:start", "foreman:start"
        @config.after "deploy:restart", "foreman:restart"
        @config.captures_responses["if [ -f /apps/foo/shared/sv/.symlink_boot ] ; then echo true ; else echo false ; fi"] = "true\n"
      end

      it "removes the start callback" do
        strategy.register
        @config.wont_have_callback_after "foreman:start", "deploy:start"
      end

     it "removes the restart callback" do
        strategy.register
        @config.wont_have_callback_after "foreman:restart", "deploy:restart"
      end
    end

    describe "without a symlink_boot" do
      before do
        @config.set :runit_sv_path, "/apps/foo/shared/sv"
        @config.set :runit_service_path, "/home/foouser/service"
        @config.after "deploy:start", "foreman:start"
        @config.after "deploy:restart", "foreman:restart"
        @config.captures_responses["if [ -f /apps/foo/shared/sv/.symlink_boot ] ; then echo true ; else echo false ; fi"] = "false\n"
      end

      it "preserves the start callback" do
        strategy.register
        @config.must_have_callback_after "deploy:start", "foreman:start"
      end

     it "preserves the restart callback" do
        strategy.register
        @config.must_have_callback_after "deploy:restart", "foreman:restart"
      end
    end
  end

  describe "#start" do
    it "starts all services without arguments" do
      @config.set :runit_service_path, "/home/foouser/service"
      @config.set :runit_app_name, "wuzzle_production"
      strategy.start

      @config.must_have_run [
        "sv start /home/foouser/service/wuzzle_production-*",
        "(s=$? && echo \"Start exited with $s\" && exit $s)"
      ].join(' || ')
    end
  end

  describe "#stop" do
    it "stops all services without arguments" do
      @config.set :runit_service_path, "/home/foouser/service"
      @config.set :runit_app_name, "wuzzle_production"
      strategy.stop

      @config.must_have_run [
        "sv stop /home/foouser/service/wuzzle_production-*",
        "(s=$? && echo \"Stop exited with $s\" && exit $s)"
      ].join(' || ')
    end
  end

  describe "#restart" do
    it "restarts all services without arguments" do
      @config.set :runit_service_path, "/home/foouser/service"
      @config.set :runit_app_name, "wuzzle_production"
      strategy.restart

      @config.must_have_run [
        "sv restart /home/foouser/service/wuzzle_production-*",
        "(s=$? && echo \"Restart exited with $s\" && exit $s)"
      ].join(' || ')
    end
  end

  describe "#ps" do
    it "returns all service process statuses" do
      @config.set :runit_service_path, "/home/foouser/service"
      @config.set :runit_app_name, "wuzzle_production"
      strategy.ps

      @config.must_have_run [
        "sv status /home/foouser/service/wuzzle_production-*",
        "(s=$? && echo \"Status exited with $s\" && exit $s)"
      ].join(' || ')
    end
  end
end
