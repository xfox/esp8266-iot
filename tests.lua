
require "lunit"
require "init"

module( "enhanced", package.seeall, lunit.testcase )

local foobar = nil

function setup()
  foobar = "Hello World"
end

function teardown()
  foobar = nil
end

function test_payload()
  payload = Payload.new(1, 2, 3, 4)
  assert_equal(Payload.format(payload), [[{time:"1", level="2", pin="3", id="4"}]])
end

function test_itterate()
  list = List.new()
  fixture = {
    Payload.new(1, 2, 3, 4),
    Payload.new(2, 3, 4, 5)
  }

  List.pushleft(list, fixture[1])
  List.pushleft(list, fixture[2])
  cnt = 1

  itterateList(list, function(payload)
    assert_equal(Payload.format(payload), Payload.format(fixture[cnt]))
    cnt = cnt + 1
  end)
end
