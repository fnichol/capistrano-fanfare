require 'capistrano'

module Capistrano::Fanfare::Airbrake
  def self.load_into(configuration)
    configuration.load do
      begin
        require 'airbrake/capistrano'

      rescue LoadError => error
        raise "airbrake gem could not be loaded: (#{error.message}). " +
          "Please ensure it is in your Gemfile."
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Airbrake.load_into(Capistrano::Configuration.instance)
end
