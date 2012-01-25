require 'capistrano'

module Capistrano::Fanfare::Ssh
  def self.load_into(configuration)
    configuration.load do
      require 'sushi/ssh'
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Fanfare::Ssh.load_into(Capistrano::Configuration.instance)
end
