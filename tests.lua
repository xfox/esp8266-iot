
require "lunit"
require "init"

module( "enhanced", package.seeall, lunit.testcase )


function setup()
end

function teardown()
end

function test_payload()
  payload = Payload.new()
  Payload.tick(payload, 1)
  Payload.tick(payload, 2)
  Payload.tick(payload, 1)
  assert_equal([[{pin_1="2",pin_2="1"}]], Payload.format(payload))
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
