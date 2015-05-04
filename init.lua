require "List"

serverHost = "ilazarev.ru"
serverURL = "ilazarev.ru/esp/"
serverPort = "80"
signalPin = 1
alarmId = 1


Payload = {}
function Payload.new(time, level, pin, id)
  assert(time ~= nil)
  assert(level ~= nil)
  assert(pin ~= nil)
  assert(id ~= nil)
  return {
    time=time,
    level=level,
    pin=pin,
    id=id
  }
end

function Payload.format(payload)
    return string.format([[{time:"%d", level="%d", pin="%d", id="%d"}]],
      payload.time, payload.level, payload.pin, payload.id
    )
end

list = List:new()

watchPin = function(pin)
  return function(level)
    payload = {
      time=tmr.time(),
      level=level,
      pin=pin,
      id=node.chipid()
    }
    List.pushleft(list, payload)
  end
end

itterateList = function(list, cb)
  isOk = true
  while isOk do
    isOk, payload = pcall(List.popright, list)
    if isOk then
      cb(payload)
    end
  end
end

sendPayload = function(list)
  conn = net.createConnection(net.TCP, 0)
  conn:on("connection", function(conn)
    itterateList(list, function (payload)      
      conn.send(Payload.format(payload))
    end)
  end)

  conn:on("disconnection", function(conn)
    conn:close()
  end)

  conn:connect(serverPort, serverHost)
end

function main()
  tmr.alarm(alarmId, 1000, sendPayload)

  gpio.trig(signalPin, "both", watchPin(signalPin))
  gpio.mode(signalPin, gpio.INT)
end
