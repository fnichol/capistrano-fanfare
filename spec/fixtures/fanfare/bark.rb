module Capistrano::Fanfare::Bark
  def self.load_into(configuration)
    configuration.load do
      task :bark do
        set :message, 'ruff ruff'
        message
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Bark.load_into(Capistrano::Configuration.instance)
end
