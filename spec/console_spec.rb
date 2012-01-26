require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/console'
require 'capistrano/fanfare/bundler'
require 'capistrano/fanfare/foreman'

describe Capistrano::Fanfare::Console do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::Console.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
  end

  describe "for variables" do
    it "sets :console_env_cmd to 'foreman run' if foreman recipe is loaded" do
      Capistrano::Fanfare::Foreman.load_into(@config)
      @config.trigger(:load)

      @config.fetch(:console_env_cmd).must_equal "foreman run"
    end

    it "sets :console_env_cmd to 'bundle exec' if foreman recipe is loaded" do
      Capistrano::Fanfare::Bundler.load_into(@config)
      @config.trigger(:load)

      @config.fetch(:console_env_cmd).must_equal "bundle exec"
    end
  end

  describe "for :console task" do
    before do
      @config.set :current_path, "/app/current"
    end

    let(:console_test) do
      [ "if [ -f /app/current/script/console ] ; then echo rails2",
        "; elif [ -f /app/current/script/rails ] ; then echo rails3",
        "; elif [ -f /app/current/config.ru -a -f /app/current/Gemfile ]",
          "&& grep 'gem.*racksh' /app/current/Gemfile >/dev/null",
          "; then echo racksh",
        "; else echo unknown ; fi"
      ].join(' ')
    end

    it "runs a rails 2.x console if script/console is detected" do
      @config.captures_responses[console_test] = "rails2\n"
      @config.find_and_execute_task("console")

      @config.must_have_run "cd /app/current &&  ./script/console production"
    end

    it "runs a rails 2.x console with 'forman run'" do
      Capistrano::Fanfare::Bundler.load_into(@config)
      Capistrano::Fanfare::Foreman.load_into(@config)
      @config.trigger(:load)
      @config.captures_responses[console_test] = "rails2\n"
      @config.find_and_execute_task("console")

      @config.must_have_run(
        "cd /app/current && foreman run ./script/console production")
    end

    it "runs a rails 2.x console with 'bundle exec'" do
      Capistrano::Fanfare::Bundler.load_into(@config)
      @config.trigger(:load)
      @config.captures_responses[console_test] = "rails2\n"
      @config.find_and_execute_task("console")

      @config.must_have_run(
        "cd /app/current && bundle exec ./script/console production")
    end

    it "runs a rails 3.x console if script/rails is detected" do
      @config.captures_responses[console_test] = "rails3\n"
      @config.find_and_execute_task("console")

      @config.must_have_run "cd /app/current &&  rails console production"
    end

    it "runs a rails 3.x console with 'foreman run'" do
      Capistrano::Fanfare::Bundler.load_into(@config)
      Capistrano::Fanfare::Foreman.load_into(@config)
      @config.trigger(:load)
      @config.captures_responses[console_test] = "rails3\n"
      @config.find_and_execute_task("console")

      @config.must_have_run(
        "cd /app/current && foreman run rails console production")
    end

    it "runs a rails 3.x console with 'bundle exec'" do
      Capistrano::Fanfare::Bundler.load_into(@config)
      @config.trigger(:load)
      @config.captures_responses[console_test] = "rails3\n"
      @config.find_and_execute_task("console")

      @config.must_have_run(
        "cd /app/current && bundle exec rails console production")
    end

    it "runs racksh if the racksh gem is detected in the Gemfile" do
      @config.captures_responses[console_test] = "racksh\n"
      @config.find_and_execute_task("console")

      @config.must_have_run "cd /app/current &&  racksh production"
    end

    it "runs racksh with 'foreman run'" do
      Capistrano::Fanfare::Bundler.load_into(@config)
      Capistrano::Fanfare::Foreman.load_into(@config)
      @config.trigger(:load)
      @config.captures_responses[console_test] = "racksh\n"
      @config.find_and_execute_task("console")

      @config.must_have_run(
        "cd /app/current && foreman run racksh production")
    end

    it "runs racksh with 'bundle exec'" do
      Capistrano::Fanfare::Bundler.load_into(@config)
      @config.trigger(:load)
      @config.captures_responses[console_test] = "racksh\n"
      @config.find_and_execute_task("console")

      @config.must_have_run(
        "cd /app/current && bundle exec racksh production")
    end

    it "raises an exception if no suitable console if found" do
      @config.captures_responses[console_test] = "unknown\n"

      proc { @config.find_and_execute_task("console") }.must_raise RuntimeError
    end
  end
end
