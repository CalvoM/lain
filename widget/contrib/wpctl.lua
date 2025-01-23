local helpers = require("lain.helpers")
local shell = require("awful.util").shell
local wibox = require("wibox")
local string = string

local function factory(args)
	args = args or {}
	local wpctl = { widget = args.widget or wibox.widget.textbox(), device = "N/A" }
	local timeout = args.timeout or 5
	local settings = args.settings or function() end

	wpctl.cmd = args.cmd or "wpctl"
	wpctl.sink = args.devicetype or "@DEFAULT_AUDIO_SINK@"

	function wpctl.update()
		helpers.async({ shell, "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@" }, function(output)
			local l, muted = string.match(output, "Volume:%s+(%d+.%d+)%s*(%g*)")
			local muted_status = false
			if string.len(muted) > 0 then
				muted_status = true
			end
			volume_now = { level = tonumber(l) * 100, status = muted_status }
			widget = wpctl.widget
			settings()
			wpctl.last = volume_now
		end)
	end
	helpers.newtimer(string.format("wpctl-viewer-default_audio_sink"), timeout, wpctl.update)
	return wpctl
end
return factory
