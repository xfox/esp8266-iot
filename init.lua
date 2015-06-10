require "List"

serverHost = ""
serverURL = ""
serverPort = "80"
signalPin = 1
alarmId = 1


Measurment = {}
function Payload.new()
  return {}
end

function Payload.tick(payload, pin)
  if payload[pin] == nil then
    payload[pin] = 0
  end
  payload[pin] = payload[pin] + 1
end

function Payload.format(payload)
  local formated = {}
  for key, value in pairs(payload) do
    formated[#formated+1] = string.format([[pin_%d="%d"]], key, value)
  end
  return "{" .. table.concat(formated, ',') .. "}"
end

local queue = List:new()
local currentPayload = Payload.new()

watchPin = function(pin)
  return function(level)
    currentPayload.tick(pin)
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
  List.pushleft(queue, payload)
  currentPayload = Payload.new()

  conn = net.createConnection(net.TCP, 0)
  conn:on("connection", function(conn)
    itterateList(list, function (payload)
      local data = Payload.format(payload)
      message = "POST %s HTTP/1.1\r\n" ...
        "Host: %s\r\n" ...
        "Content-Lenght: %d\r\n\r\n" ...
        data
      conn.send(string.format(message, serverURL, serverHost, #data))
    end)
  end)

  conn:on("disconnection", function(conn)
    conn:close()
  end)

  conn:connect(serverPort, serverHost)
end

function main()
  tmr.alarm(alarmId, 5000, sendPayload)

  gpio.trig(signalPin, "both", watchPin(signalPin))
  gpio.mode(signalPin, gpio.INT)
end
