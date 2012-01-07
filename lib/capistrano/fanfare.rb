require "capistrano"
require "capistrano/fanfare/version"

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.load_paths << File.dirname(__FILE__)
end

module Capistrano
  module Fanfare
    module Configuration
      def fanfare_recipe(recipe)
        require "capistrano/fanfare/#{recipe}"
      end
    end
  end
end

module Capistrano
  class Configuration
    include Capistrano::Fanfare::Configuration
  end
end
