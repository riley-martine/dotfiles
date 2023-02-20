#!/usr/bin/env lua
local cards = {}

local f = assert(io.open("cards.txt", "r"))
for line in f:lines() do
	local card = {}
	line:gsub("([^|]+)", function(c)
		-- trim beginning whitespace
		c = c:match("^%s*(.*)%s*$")
		table.insert(card, c)
	end)
	cards[#cards + 1] = card
end

f:close()

local strategies = {}
local f = assert(io.open("strategies.txt", "r"))
for line in f:lines() do
	strategies[#strategies + 1] = line
end

print("WELCOME TO THE DEBUGGING WIZARD")
print("STATE YOUR QUERY:")
local query = io.read("l")
math.randomseed(os.time() + #query)

card = cards[math.random(#cards)]
strategy = strategies[math.random(#strategies)]

print("")
print("YOUR DRAW IS: ")
print("    " .. card[1] .. ":: " .. strategy)
print("")
print("THE TRADITIONAL MEANING:")
print("    " .. card[2])
print("AND WITHIN, THE OBVERSE:")
print("    " .. card[3])
