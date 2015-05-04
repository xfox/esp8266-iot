
require "lunit"
require "script1"

module( "enhanced", package.seeall, lunit.testcase )

local foobar = nil

function setup()
  foobar = "Hello World"
end

function teardown()
  foobar = nil
end

function test_list()
  payload = Payload.new(1, 2, 3, 4)
  assert_equal(Payload.format(payload), [[{time:"1", level="2", pin="3", id="4"}]])

end
