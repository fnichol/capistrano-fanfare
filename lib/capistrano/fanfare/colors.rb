require 'capistrano'

module Capistrano::Fanfare::Colors
  def self.load_into(configuration)
    configuration.load do
      require 'capistrano_colors'

      colorize({ :match => /^out ::.*$/, :color => :magenta, :prio => 20 })
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Colors.load_into(Capistrano::Configuration.instance)
end
