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

      def fanfare_require(gem_name, path = gem_name)
        require path
      rescue LoadError => error
        raise "#{gem_name} gem could not be loaded: (#{error.message}). " +
          "Please ensure it is in your Gemfile."
      end
    end
  end
end

module Capistrano
  class Configuration
    # injects a fanfare_recipe helper method which can be used in the Capfile
    include Capistrano::Fanfare::Configuration
  end
end
