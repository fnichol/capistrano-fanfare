module Capistrano::Fanfare::Defaults
  def self.load_into(configuration)
    configuration.load do
      set :scm,         :git
      set :use_sudo,    false
      set :user,        "deploy"
      set(:branch)      { ENV['BRANCH'] ? ENV['BRANCH'] : "master" }
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Defaults.load_into(Capistrano::Configuration.instance)
end
