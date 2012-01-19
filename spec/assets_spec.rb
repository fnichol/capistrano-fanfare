require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/assets'

#
# Rake mixes in FileUtils methods into Capistrano::Configuration::Namespace as
# private methods which will cause a method/task namespace collision when the
# `deploy:assets:symlink' task is created.
#
# So, if we are in a Rake context, nuke :symlink in the Namespace class--we
# won't be using it directly in this codebase but this feels so very, very
# wrong (here be dragons).
#
if defined?(Rake::DSL)
  Capistrano::Configuration::Namespaces::Namespace.class_eval { undef :symlink }
end

describe Capistrano::Fanfare::Assets do
  before do
    @config = Capistrano::Configuration.new
    Capistrano::Fanfare::Assets.load_into(@config)
    @config.extend(MiniTest::Capistrano::ConfigurationExtension)
    # @orig_config = Capistrano::Configuration.instance
    # Capistrano::Configuration.instance = @config
  end

  after do
    # Capistrano::Configuration.instance = @orig_config
  end

  describe "for namespace :deploy" do
    it "creates a deploy:assets:symlink task" do
      @config.must_have_task "deploy:assets:symlink"
    end

    it "creates a deploy:assets:precompile task" do
      @config.must_have_task "deploy:assets:precompile"
    end

    it "creates a deploy:assets:clean task" do
      @config.must_have_task "deploy:assets:clean"
    end
  end
end
