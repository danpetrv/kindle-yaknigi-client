-- The cover on the sleep screen filling it, as CSS's background-size: cover: scaled until no
-- side of the screen is left bare, what stands out cut off evenly. KOReader can only fit a
-- picture whole or stretch it out of shape.
local SleepCover = {}

--- The scale that makes a picture of w x h cover a screen of sw x sh. A pixel over, as the
-- library's covers do: the factor is rounded down on the way to a whole number of pixels.
function SleepCover.fill_scale(w, h, sw, sh)
    return math.max((sw + 1) / w, (sh + 1) / h)
end

--- The picture as large as the screen, from the cover's file; nil when it cannot be read.
function SleepCover.render(file)
    local Blitbuffer = require("ffi/blitbuffer")
    local ImageWidget = require("ui/widget/imagewidget")
    local RenderImage = require("ui/renderimage")
    local Screen = require("device").screen

    local w, h = Screen:getWidth(), Screen:getHeight()
    -- KOReader turns image screensavers to portrait before showing them.
    if Screen:getRotationMode() % 2 == 1 then w, h = h, w end
    local image = file and RenderImage:renderImageFile(file, false)
    if not image then return nil end
    -- Larger than the box it is given, an ImageWidget shows the middle of the picture.
    local picture = ImageWidget:new{
        image = image,
        width = w,
        height = h,
        scale_factor = SleepCover.fill_scale(image:getWidth(), image:getHeight(), w, h),
        alpha = true,
        original_in_nightmode = false,
    }
    local canvas = Blitbuffer.new(w, h, Screen:isColorEnabled() and Blitbuffer.TYPE_BBRGB32 or Blitbuffer.TYPE_BB8)
    canvas:fill(Blitbuffer.COLOR_WHITE)
    picture:paintTo(canvas, 0, 0)
    picture:free()
    return canvas
end

return SleepCover
