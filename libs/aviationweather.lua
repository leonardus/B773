-- used by TAF and METAR commands

local http = require("coro-http")
local xml = require("xml2lua")
local handler = require("xmlhandler/tree")

return function(client, message, args, dataSource)
    if #args < 1 then
        message.channel:send(message.author.mentionString .. " Not enough arguments.")
        return
    end

    local icao = args[1]
    if icao:match("%a+") ~= icao then
        message.channel:send(message.author.mentionString .. " Invalid ICAO code.")
        return
    end

    local url = "https://aviationweather.gov/adds/dataserver_current/httpparam?dataSource=" .. dataSource .. "&requestType=retrieve&format=xml&hoursBeforeNow=24&mostRecent=true&stationString=" .. icao
    local res, body = http.request("GET", url)
    if res.code == 200 then
        handler = handler:new()
        xml.parser(handler):parse(body)
        local doc = handler.root

        if tonumber(doc.response.data._attr.num_results) < 1 then
            message.channel:send("No results for " .. icao:upper() .. ".")
        else
            local field
            if dataSource:lower() == "metars" then
                field = "METAR"
            elseif dataSource:lower() == "tafs" then
                field = "TAF"
            end
            message.channel:send(handler.root.response.data[field].raw_text)
        end
    else
        message.channel:send("Something went wrong. The error has been reported.")
        print(res.code, body)
    end
end