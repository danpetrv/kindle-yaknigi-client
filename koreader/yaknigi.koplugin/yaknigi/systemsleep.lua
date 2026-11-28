-- The Kindle's own sleep screen, as chosen in the Kindle's settings, instead of KOReader's.
-- KOReader already leaves sleep to the Kindle on devices with ads: on the way to sleep it wakes
-- the Kindle's interface to draw its screen, and stops it again on the way back. It goes that way
-- when Device:supportsScreensaver() says no; here it says no while the choice is the Kindle's own.
local SystemSleep = {}

--- Wraps device's way into sleep and out of it: when wanted() holds, they run as on a device
-- that draws no sleep screen of its own. The same choice both ways, as it cannot change asleep.
function SystemSleep.install(device, wanted)
    for _, name in ipairs{ "intoScreenSaver", "outofScreenSaver" } do
        local original = device[name]
        if original then
            device[name] = function(self, ...)
                if not wanted() then return original(self, ...) end
                -- Its own, if it had one; else what its class says, once this is gone.
                local own = rawget(self, "supportsScreensaver")
                self.supportsScreensaver = function() return false end
                local ok, err = pcall(original, self, ...)
                self.supportsScreensaver = own
                if not ok then error(err, 0) end
            end
        end
    end
end

return SystemSleep
