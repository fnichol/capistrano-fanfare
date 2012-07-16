require 'capistrano'

module Capistrano::Fanfare::Airbrake
  def self.load_into(configuration)
    configuration.load { fanfare_require 'airbrake', 'airbrake/capistrano' }
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Airbrake.load_into(Capistrano::Configuration.instance)
end
