local aviationweather = require("aviationweather")

return function(client, message, args)
    aviationweather(client, message, args, "tafs")
end