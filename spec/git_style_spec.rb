require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/git_style'
require 'timecop'

describe Capistrano::Fanfare::GitStyle do
  before do
    @config = Capistrano::Configuration.new
    @config.load "deploy"
    Capistrano::Fanfare::GitStyle.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)

    @config.set :application, "fooapp"
    @config.set :repository, "git@example.com:fooapp.git"
  end

  describe "for variables" do
    it "sets :scm to :git" do
      @config.fetch(:scm).must_equal :git
    end

    it "sets :deploy_via to :git_style" do
      @config.fetch(:deploy_via).must_equal :git_style
    end

    it "sets :release_name to a timestamp and git commit id" do
      @config.set :real_revision, "git123"

      Timecop.freeze(Time.utc(2012, 1, 1, 2, 3, 4)) do
        @config.fetch(:release_name).must_equal "20120101020304-git123"
      end
    end

    it "sets :release_path to :current_path" do
      @config.fetch(:release_path).must_equal @config.fetch(:current_path)
    end

    it "sets :latest_release to :current_path" do
      @config.fetch(:latest_release).must_equal @config.fetch(:current_path)
    end

    it "sets :current_revision to current git revision on server" do
      @config.set :current_path, "/a/apps/barapp/current"
      capture_cmd = "cd /a/apps/barapp/current && git rev-parse HEAD"
      @config.captures_responses[capture_cmd] = "gitZZZ"

      @config.fetch(:current_revision).must_equal "gitZZZ"
    end

    it "sets :latest_revision to current git revision on the server" do
      @config.set :current_release, "/a/apps/zurb/releases/20120101020304-gitFAB"
      capture_cmd = "basename /a/apps/zurb/releases/20120101020304-gitFAB | cut -d - -f 2"
      @config.captures_responses[capture_cmd] = "gitFAB"

      @config.fetch(:latest_revision).must_equal "gitFAB"
    end

    it "sets :previous_revision to git revision of last deployment" do
      @config.set :previous_release, "/a/apps/zurb/releases/20060212125959-gitCC"
      capture_cmd = "basename /a/apps/zurb/releases/20060212125959-gitCC | cut -d - -f 2"
      @config.captures_responses[capture_cmd] = "gitCC"

      @config.fetch(:previous_revision).must_equal "gitCC"
    end

    it "sets :previous_revision to nil if :previous_release is not set" do
      @config.set :previous_release, nil

      @config.captures.must_be_empty
      @config.fetch(:previous_revision).must_be_nil
    end
  end

  describe "for namespace :deploy" do
    describe "task :update_code" do
      before do
        @config.load do
          def methods_called ; @methods_called ||= [] ; end

          namespace :deploy do
            task(:finalize_update) { methods_called << "deploy:finalize_update" }
          end
        end

        # stub out strategy.deploy!
        strategy = @config.strategy
        def strategy.deploy! ; methods_called << "strategy.deploy!" ; end

        # stub out on_rollback
        def @config.on_rollback ; methods_called << "on_rollback" ; end
      end

      it "calls same tasks as delivered gem code" do
        @config.find_and_execute_task("deploy:update_code")

        @config.methods_called.must_equal(["strategy.deploy!", "deploy:finalize_update"])
      end
    end

    it "task :create_symlink must not run anything (no-op)" do
      @config.find_and_execute_task("deploy:create_symlink")

      @config.wont_have_run_anything
    end

    describe "task :cold" do
      before do
        @config.load do
          def methods_called ; @methods_called ||= [] ; end

          namespace :deploy do
            task(:update)   { methods_called << "deploy:update" }
            task(:migrate)  { methods_called << "deploy:migrate" }
            task(:start)    { methods_called << "deploy:start" }
          end
        end
      end

      it "calls same tasks as delivered gem code" do
        @config.find_and_execute_task("deploy:cold")

        @config.methods_called.must_equal(
          ["deploy:update", "deploy:migrate", "deploy:start"])
      end

      it "calls db:seed if the task exists" do
        @config.namespace :db do
          task(:seed) { methods_called << "db:seed" }
        end
        @config.find_and_execute_task("deploy:cold")

        @config.methods_called.must_include "db:seed"
      end
    end

    describe "in namespace :rollback" do
      before do
        @config.load do
          def methods_called ; @methods_called ||= [] ; end

          namespace :deploy do
            task(:update_code) { methods_called << "deploy:update_code" }
          end
        end
      end

      def runs_msg(cmd)
        runs_list = @config.runs.keys.sort.
          map { |c|c.sub(/^/, '\'').sub(/$/, '\'')}.join(', ')
        "Expected run call of '#{cmd}' in run list of: [#{runs_list}]"
      end

      it "task :revision sets :branch to :previous_release" do
        @config.set :branch, "ding"
        @config.set :previous_revision, "gitPREV"
        @config.set :previous_release, "/u/apps/rofl/releases/20080808082800-gitPREV"
        @config.find_and_execute_task("deploy:rollback:revision")

        @config.fetch(:branch).must_equal "gitPREV"
      end

      it "task :revision runs deploy:update_code" do
        @config.set :previous_revision, "gitPREV"
        @config.set :previous_release, "/u/apps/rofl/releases/20080808082800-gitPREV"
        @config.find_and_execute_task("deploy:rollback:revision")

        @config.methods_called.must_include "deploy:update_code"
      end

      it "task :revision raises an exception if no previous release exists" do
        @config.set :previous_release, nil

        proc { @config.find_and_execute_task("deploy:rollback:revision") }.
          must_raise RuntimeError
        @config.methods_called.wont_include "deploy:update_code"
      end

      it "task :cleanup removes :current_release directory conditionally" do
        @config.set :current_path, "/u/apps/rofl/current"
        @config.set :latest_revision, "gitAAA"
        @config.set :current_release, "/u/apps/rofl/releases/20120101020304-gitAAA"
        @config.find_and_execute_task("deploy:rollback:cleanup")

        cmd = [
          "if [ `(cd /u/apps/rofl/current && git rev-parse HEAD)` != `gitAAA` ]; " +
          "then rm -rf /u/apps/rofl/releases/20120101020304-gitAAA; fi"
        ]
        @config.must_have_run cmd.join, runs_msg(cmd.join)
      end
    end
  end
end
