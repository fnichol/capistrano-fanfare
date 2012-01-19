require 'minitest/autorun'
require 'minitest/capistrano'
require 'capistrano/fanfare'
require 'capistrano/fanfare/colors'

describe Capistrano::Fanfare::Colors do
  # This recipe is not being tested as it patches Capistrano's log
  # method and causes random failures in the rest of the test suite.
end
