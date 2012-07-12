require 'minitest/autorun'
require 'minitest/capistrano'
require 'mocha'
require 'capistrano/fanfare'
require 'capistrano/fanfare/campfire'

class MockRoom
  attr_reader :speaks, :plays

  def speak(msg)
    @speaks ||= []
    @speaks << msg
  end

  def play(clip)
    @plays ||= []
    @plays << clip
  end
end

describe Capistrano::Fanfare::Campfire do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::Campfire.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)

    ENV['_SPEC_USER'] = ENV['USER']
    ENV['USER'] = 'filbert'
    ENV['_SPEC_REASON'] = ENV['REASON']
    ENV['REASON'] = "to deal with the tribbles"
    ENV['_SPEC_CAMPFIRE_YAML_FILE'] = ENV['CAMPFIRE_YAML_FILE']
    ENV['CAMPFIRE_YAML_FILE'] = File.join(
      File.dirname(__FILE__), %w{fixtures campfire campfire.yml})

    @config.load do
      def puts(msg)
        @outputs ||= []
        @outputs << msg
      end

      def outputs ; @outputs ; end

      def campfire_room
        @room ||= MockRoom.new
      end
    end
  end

  after do
    ENV['USER'] = ENV.delete('_SPEC_USER')
    ENV['REASON'] = ENV.delete('_SPEC_REASON')
    ENV['CAMPFIRE_YAML_FILE'] = ENV.delete('_CAMPFIRE_YAML_FILE')
  end

  describe "for variables" do
    it "sets :campfire_yaml_file to the value from ENV['CAMPFIRE_YAML_FILE']" do
      @config.fetch(:campfire_yaml_file).must_equal(File.expand_path(
        File.join(File.dirname(__FILE__), %w{fixtures campfire campfire.yml})))
    end

    it "sets :campfire_yaml_file to ~/.campfire.yaml if no ENV var is set" do
      ENV.delete('CAMPFIRE_YAML_FILE')
      File.stubs(:exists?).with(File.expand_path('~/.campfire.yml')).returns(true)

      @config.fetch(:campfire_yaml_file).must_equal(
        File.expand_path('~/.campfire.yml'))
    end

    it "raises an exception if :campfire_yaml_file file does not exist" do
      ENV['CAMPFIRE_YAML_FILE'] = "/path/to/nowhere"

      proc { @config.trigger(:load) }.must_raise RuntimeError
    end

    it "loads the campfire configuration into the :campfire_options hash" do
      @config.fetch(:campfire_options)[:account].must_equal("fitznuggets")
      @config.fetch(:campfire_options)[:token].must_equal("abcdefg")
      @config.fetch(:campfire_options)[:room].must_equal("nuggettalk")
      @config.fetch(:campfire_options)[:ssl].must_equal(true)
    end

    it "sets :campfire_room to a campfire room object" do
      Campy::Room.expects(:new).with(:account => "fitznuggets",
        :room => "nuggettalk", :token => "abcdefg", :ssl => true)

      @config.fetch(:campfire_room)
    end

    it "sets :campfire_pre_msg to a known default" do
      @config.set :application, 'wazup'
      @config.set :deploy_env, 'staging'
      @config.set :branch, "master"

      @config.fetch(:campfire_pre_msg).must_equal(
        "filbert is starting a deploy of wazup from master to staging")
    end

    it "sets :campfire_success_msg to a known default" do
      @config.fetch(:campfire_success_msg).must_equal(
        "Deployment started by filbert succeeded.")
    end

    it "sets :campfire_fail_msg to a known default" do
      @config.fetch(:campfire_fail_msg).must_equal(
        "Deployment started by filbert failed, so attempting to roll back.")
    end

    it "sets :campfire_web_disable_msg to a known default containing the reason given" do
      @config.set :application, 'wazup'
      @config.set :deploy_env, 'staging'

      @config.fetch(:campfire_web_disable_msg).must_equal([
        'filbert is bringing wazup_staging down into maintenance mode',
        '("to deal with the tribbles").'].join(' '))
    end

    it "sets :campfire_web_enable to a known default" do
      @config.set :application, 'wazup'
      @config.set :deploy_env, 'staging'

      @config.fetch(:campfire_web_enable_msg).must_equal(
        "filbert is bringing wazup_staging back from maintenance mode.")
    end

    it "sets :campfire_success_play to 'pushit'" do
      @config.fetch(:campfire_success_play).must_equal "pushit"
    end

    it "sets :campfire_fail_play to 'trombone'" do
      @config.fetch(:campfire_fail_play).must_equal "trombone"
    end
  end

  describe "for methods" do
    describe "#deploy_env_formatted" do
      it "returns the :deploy_env if it is not production" do
        @config.set :deploy_env, "load_testing"

        @config.deploy_env_formatted.must_equal "load_testing"
      end

      it "can handle :deploy_env as a symbol" do
        @config.set :deploy_env, :staging

        @config.deploy_env_formatted.must_equal "staging"
      end

      it "downcases the :deploy_env" do
        @config.set :deploy_env, "THEKINGSTAGE"

        @config.deploy_env_formatted.must_equal "thekingstage"
      end

      it "surrounds :deploy_env with stars and upcase when it starts with 'prod'" do
        @config.set :deploy_env, "produc"

        @config.deploy_env_formatted.must_equal "**PRODUC**"
      end
    end

    describe "#speak" do
      it "speaks in a campfire room" do
        @config.speak("yo")

        @config.campfire_room.speaks.first.must_equal "yo"
      end

      it "prints out a message if in dry run" do
        @config.dry_run = true
        @config.speak("yo")

        @config.outputs.first.must_equal "[campfire.speak]: yo"
      end
    end

    describe "#play" do
      it "plays a clip in a campfire room" do
        @config.play("tada")

        @config.campfire_room.plays.first.must_equal "tada"
      end

      it "prints out a message if in dry run" do
        @config.dry_run = true
        @config.play("live")

        @config.outputs.first.must_equal "[campfire.play]: live"
      end
    end
  end

  describe "for namespace :campfire" do
    describe "task :pre_deploy" do
      it "prints a message in campfire" do
        @config.set :campfire_pre_msg, "giddy up, yo"
        @config.find_and_execute_task("campfire:pre_deploy")

        @config.campfire_room.speaks.first.must_equal "giddy up, yo"
      end

      it "gets called before deploy task" do
        @config.must_have_callback_before "deploy", "campfire:pre_deploy"
      end

      it "gets called before deploy:migrations task" do
        @config.must_have_callback_before "deploy:migrations", "campfire:pre_deploy"
      end

      it "gets called before deploy:cold task" do
        @config.must_have_callback_before "deploy:cold", "campfire:pre_deploy"
      end
    end

    describe "task :successful_deploy" do
      it "print a message in campfire" do
        @config.set :campfire_success_msg, "you did it bro"
        @config.find_and_execute_task("campfire:successful_deploy")

        @config.campfire_room.speaks.first.must_equal "you did it bro (0 seconds)"
      end

      it "play a sound in campfire" do
        @config.set :campfire_success_play, "blahblah"
        @config.find_and_execute_task("campfire:successful_deploy")

        @config.campfire_room.plays.first.must_equal "blahblah"
      end

      it "gets called after deploy task" do
        @config.must_have_callback_after "deploy", "campfire:successful_deploy"
      end

      it "gets called after deploy:migrations task" do
        @config.must_have_callback_after "deploy:migrations", "campfire:successful_deploy"
      end

      it "gets called after deploy:cold task" do
        @config.must_have_callback_after "deploy:cold", "campfire:successful_deploy"
      end
    end

    describe "task :rollback_deploy" do
      it "prints a message in campfire" do
        @config.set :campfire_fail_msg, "you = fail dude"
        @config.find_and_execute_task("campfire:rollback_deploy")

        @config.campfire_room.speaks.first.must_equal "you = fail dude"
      end

      it "play a sound in campfire" do
        @config.set :campfire_fail_play, "whawha"
        @config.find_and_execute_task("campfire:rollback_deploy")

        @config.campfire_room.plays.first.must_equal "whawha"
      end

      it "gets called before deploy:rollback task" do
        @config.must_have_callback_before "deploy:rollback", "campfire:rollback_deploy"
      end
    end

    describe "task :web_disable" do
      it "prints a message in campfire" do
        @config.set :campfire_web_disable_msg, "website offline"
        @config.find_and_execute_task("campfire:web_disable")

        @config.campfire_room.speaks.first.must_equal "website offline"
      end

      it "gets called before deploy task" do
        @config.must_have_callback_before "deploy:web:disable", "campfire:web_disable"
      end
    end

    describe "task :web_enable" do
      it "prints a message in campfire" do
        @config.set :campfire_web_enable_msg, "we're back baby"
        @config.find_and_execute_task("campfire:web_enable")

        @config.campfire_room.speaks.first.must_equal "we're back baby"
      end

      it "gets called before deploy task" do
        @config.must_have_callback_before "deploy:web:enable", "campfire:web_enable"
      end
    end
  end
end
