require "capistrano"
require "capistrano/fanfare/version"

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.load_paths << File.dirname(__FILE__)
end

module Capistrano
  module Fanfare
  end
end
