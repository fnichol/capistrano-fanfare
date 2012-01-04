require 'minitest/autorun'
require 'capistrano/fanfare'

describe Capistrano::Fanfare do
  before do
    @config = Capistrano::Configuration.new
    @config.load_paths << File.expand_path(File.join(File.dirname(__FILE__), "recipes"))
    Capistrano::Configuration.instance = @config
  end

  it 'loads a fanfare capistrano recipe' do
    @config.load 'fanfare/bark'

    @config.find_and_execute_task("bark").must_equal "ruff ruff"
    @config.fetch(:message).must_equal "ruff ruff"
  end
end
