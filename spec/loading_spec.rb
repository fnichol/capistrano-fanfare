require 'minitest/autorun'
require 'capistrano'

module Capistrano::Fanfare ; end

describe Capistrano::Fanfare do
  before do
    @config = Capistrano::Configuration.new
    @config.load_paths << File.join(File.dirname(__FILE__), "recipes")
    Capistrano::Configuration.instance = @config
  end

  it 'load_paths include capistrano/ in gem' do
    require 'capistrano/fanfare'
    @config.load_paths.must_include File.expand_path(
      File.join(File.dirname(__FILE__), %w{.. lib capistrano}))
  end

  it 'loads a fanfare capistrano recipe' do
    @config.load 'fanfare/bark'

    @config.find_and_execute_task("bark").must_equal "ruff ruff"
    @config.fetch(:message).must_equal "ruff ruff"
  end
end
