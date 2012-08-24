require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/log'
require 'mocha'

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

    describe "task :view" do
      before do
        @config.stubs(:log_exec).returns(true)
        @tempfile = Tempfile.open('w')
        Tempfile.stubs(:open).with('w').returns(@tempfile)
      end

      describe "resolving log file" do
        it "runs a tail on a log file based on :rails_env variable" do
          @config.set :rails_env, "uat"
          @config.find_and_execute_task("log:view")

          @config.must_have_run "/usr/bin/tail -n 500 /my/path/log/uat.log"
        end

        it "runs a tail on a log file based on :rack_env variable" do
          @config.set :rack_env, "staging"
          @config.find_and_execute_task("log:view")

          @config.must_have_run "/usr/bin/tail -n 500 /my/path/log/staging.log"
        end

        it "runs a tail of the production log file if :rails_env and :rack_env does not exist" do
          @config.find_and_execute_task("log:view")

          @config.must_have_run "/usr/bin/tail -n 500 /my/path/log/production.log"
        end
      end

      it "runs a tail on a log file with a specified line count" do
        ENV['_SPEC_n'] = ENV['n']
        ENV['n'] = '987'
        @config.find_and_execute_task("log:view")

        @config.must_have_run "/usr/bin/tail -n 987 /my/path/log/production.log"
        ENV['n'] = ENV.delete('_SPEC_n')
      end

      describe "resolving an editor" do
        ENV_EDITORS = %w{VISUAL EDITOR editor}

        before do
          ENV_EDITORS.each do |e|
            ENV["_SPEC_#{e}"] = ENV[e]
            ENV.delete(e)
          end
        end

        after do
          ENV_EDITORS.each do |e|
            ENV[e] = ENV.delete("_SPEC_#{e}")
          end
        end

        it "opens the logfile in vi by default" do
          @config.expects(:log_exec).with("vi #{@tempfile.path}")

          @config.find_and_execute_task("log:view")
        end

        ENV_EDITORS.each do |v|
          it "opens the logfile in the editor in ENV['#{v}']" do
            ENV[v] = "/this/editor/#{v}"
            @config.expects(:log_exec).with("#{ENV[v]} #{@tempfile.path}")

            @config.find_and_execute_task("log:view")
          end
        end
      end
    end
  end
end
