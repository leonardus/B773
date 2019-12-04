local discordia = require("discordia")
local cmdlist = require("./cmdlist")
local readfile = require("readfile")
local explode = require("explode")
local toml = require("toml")
local settings = toml.parse(readfile("config.toml"))

local client = discordia.Client()
client:on("ready", function()
	print("Logged in as " .. client.user.username)
end)
client:on("messageCreate", function(message)
	for user in message.mentionedUsers:iter() do
		if user == client.user then
			local sanitized = message.content
				:gsub("<@%d+>", "") --remove @mentions
				:gsub("^%s+", "") --trim beginning spaces
				:gsub("%s+$", "") --trim ending spaces
				:gsub("%s+", " ") --shrink multiple spaces to just one
			local parsed = explode(" ", sanitized)
			if #parsed >= 1 then
				local command = parsed[1]:upper()
				local args = {}
				if #parsed >= 2 then
					for i = 2, #parsed do
						table.insert(args, parsed[i])
					end
				end
				if cmdlist[command] then
					cmdlist[command](client, message, args)
				end
			end
		end
	end
end)

client:run("Bot " .. settings.token)