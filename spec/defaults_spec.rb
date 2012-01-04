require 'minitest/autorun'
require 'capistrano/fanfare'
require 'capistrano/fanfare/defaults'

describe Capistrano::Fanfare::Defaults do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::Defaults.load_into(@config)
    ENV['BRANCH'] = nil
  end

  it "sets :scm to :git" do
    @config.fetch(:scm).must_equal :git
  end

  it "sets :use_sudo to false" do
    @config.fetch(:use_sudo).must_equal false
  end

  it "sets :user to 'deploy'" do
    @config.fetch(:user).must_equal "deploy"
  end

  describe ':branch' do
    it "sets to master by default" do
      @config.fetch(:branch).must_equal "master"
    end

    it "sets :branch to ENV['BRANCH'] if set" do
      ENV['BRANCH'] = "tree-branch"

      @config.fetch(:branch).must_equal "tree-branch"
    end
  end
end
