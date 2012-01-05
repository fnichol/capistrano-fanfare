require 'minitest/spec'

module MiniTest
  module Assertions
    def assert_have_run(cmd, configuration, msg = nil)
      msg = message(msg) { "Expected configuration to run #{cmd}, but did not" }
      refute_nil configuration.runs[cmd], msg
    end

    def refute_have_run(cmd, configuration, msg = nil)
      msg = message(msg) { "Expected configuration to not run #{cmd}, but did" }
      assert_nil configuration.runs[cmd], msg
    end
  end

  module Expectations
    ##
    # See MiniTest::Assertions#assert_have_run
    #
    #    config.must_have_run cmd
    #
    # :method: must_have_run

    infect_an_assertion :assert_have_run, :must_have_run

    ##
    # See MiniTest::Assertions#refute_have_run
    #
    #    config.wont_have_run cmd
    #
    # :method: wont_have_run

    infect_an_assertion :refute_have_run, :wont_have_run
  end
end

class Object
  include MiniTest::Expectations
end
