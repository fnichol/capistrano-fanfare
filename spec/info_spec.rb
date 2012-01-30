require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/info'

describe Capistrano::Fanfare::Info do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::Info.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
  end

  describe "for variables" do
    it "sets :info_variables to a known default" do
      @config.fetch(:info_variables).must_equal [
        :application, :repository, :branch, :deploy_env,
        :user, :deploy_to, :rails_env
      ]
    end
  end

  it "prints the configuration information" do
    @config.set :application, "foogle"
    @config.set :repository, "git@example.com:foogle.git"
    @config.set :info_variables, [:application, :repository]
    io = StringIO.new
    @config.logger = Capistrano::Logger.new(:output => io)
    @config.find_and_execute_task("info")

    io.string.must_equal [
      %{*** Configuration:},
      %{*** * application: "foogle"},
      %{*** * repository: "git@example.com:foogle.git"}
    ].join("\n").concat("\n")
  end
end
