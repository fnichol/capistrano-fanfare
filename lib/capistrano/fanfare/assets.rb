require 'capistrano'

module Capistrano::Fanfare::Assets
  def self.load_into(configuration)
    configuration.load do
      load 'deploy/assets'
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Assets.load_into(Capistrano::Configuration.instance)
end
