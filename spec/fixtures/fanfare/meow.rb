module Capistrano::Fanfare::Meow
  def self.load_into(configuration)
    configuration.load do
      task :meow do
        'purr purr'
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Meow.load_into(Capistrano::Configuration.instance)
end

