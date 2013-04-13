--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require("luci.sys")
require("luci.util")
require("luci.tools.webadmin")
require("luci.fs")
local arg1 = arg[1]
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()

if not luci.fs.access("/etc/config/bacnet_mv") then
	if not luci.sys.exec("touch /etc/config/bacnet_mv") then
		return
	end
end

if arg1 then
	m = Map("bacnet_mv_"..arg1, "Bacnet Multisate Value", "Bacnet Multisate Value Configuration")
else
	m = Map("bacnet_mv", "Bacnet Multisate Value", "Bacnet Multisate Value Configuration")
end

s = m:section(TypedSection, "mv", arg1 or 'MV Index')
s.addremove = true
s.anonymous = false
s.template = "cbi/tblsection"

s:option(Flag, "disable", "Disable")
s:option(Value, "name", "MV Name")

sva = s:option(Value, "tagname",  "Zugrifsname")
uci:foreach("linknx", "daemon",
	function (section)
			sva:value(section.tagname)
	end)
uci:foreach("modbus", "station",
	function (section)
			sva:value(section.tagname)
	end)
sva:value("icinga")

s:option(Value, "addr", "Addr")
s:option(Value, "value", "Value")
s:option(DynamicList, "state", "Stats")
s:option(DynamicList, "alarmstate", "Alarm Stats")

sva = s:option(Value, "group",  "Gruppe")
local uci = luci.model.uci.cursor()
uci:foreach("bacnet_group", "group",
	function (section)
			sva:value(section.name)
	end)

s:option(Value, "description", "Anzeige Name")
s:option(Flag, "tl", "Trend Log")
svc = s:option(Value, "nc", "Notification Class")
svc.rmempty = true
local uci = luci.model.uci.cursor()
uci:foreach("bacnet_nc", "nc",
	function (section)
			sva:value(section,section.name)
	end)
sva = s:option(Value, "event",  "BIT1 Alarm,BIT2 Fehler,BIT3 Alarm oder Fehler geht [7]")
sva:value(0,"Keine Ereignis Behandlung")
sva:value(7,"Alle Ereignis behandeln")

return m
