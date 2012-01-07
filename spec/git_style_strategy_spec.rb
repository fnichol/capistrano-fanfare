require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano'
require 'capistrano/recipes/deploy/scm'
require 'capistrano/recipes/deploy/strategy/git_style'

describe Capistrano::Deploy::Strategy::GitStyle do
  before do
    @config = Capistrano::Configuration.new
    @config.set :release_path,  "/u/apps/fooapp/releases/20120101020304-gitABC123"
    @config.set :current_path,  "/u/apps/fooapp/current"
    @config.set :real_revision, "gitABC123"
    @config.set :source,        Capistrano::Deploy::SCM.new(:git, @config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)

    @strategy = Capistrano::Deploy::Strategy::GitStyle.new(@config)
  end

  def runs_msg(cmd)
    runs_list = @config.runs.keys.sort.
      map { |c|c.sub(/^/, '\'').sub(/$/, '\'')}.join(', ')
    "Expected run call of '#{cmd}' in run list of: [#{runs_list}]"
  end

  it "deploys a git checkout if fresh and a git fetch if existing" do
    @strategy.deploy!

    cmd = [
      "if [ -d /u/apps/fooapp/current/.git ]; then ",
        "cd /u/apps/fooapp/current && git fetch -q origin && ",
        "git fetch --tags -q origin && git reset -q --hard gitABC123 && ",
        "git clean -q -d -x -f; ",
      "else ",
        "git clone -q /u/apps/fooapp/current && ",
        "cd /u/apps/fooapp/current && git checkout -q -b deploy gitABC123; ",
      "fi && ",
      "(mkdir -p /u/apps/fooapp/releases/20120101020304-gitABC123)"
    ]
    @config.runs[cmd.join].wont_be_nil(runs_msg(cmd.join))
  end
end
