-- Color manipulation: hex/rgb/hsl conversion and transforms
local M = {}

function M.hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return {
    r = tonumber(hex:sub(1, 2), 16),
    g = tonumber(hex:sub(3, 4), 16),
    b = tonumber(hex:sub(5, 6), 16),
  }
end

function M.rgb_to_hex(rgb)
  return string.format("#%02x%02x%02x",
    math.floor(math.min(255, math.max(0, rgb.r))),
    math.floor(math.min(255, math.max(0, rgb.g))),
    math.floor(math.min(255, math.max(0, rgb.b)))
  )
end

function M.rgb_to_hsl(rgb)
  local r, g, b = rgb.r / 255, rgb.g / 255, rgb.b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l = 0, 0, (max + min) / 2

  if max ~= min then
    local d = max - min
    s = l > 0.5 and d / (2 - max - min) or d / (max + min)

    if max == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end
    h = h / 6
  end

  return { h = h * 360, s = s, l = l }
end

function M.hsl_to_rgb(hsl)
  local h, s, l = hsl.h / 360, hsl.s, hsl.l

  if s == 0 then
    local v = math.floor(l * 255)
    return { r = v, g = v, b = v }
  end

  local function hue_to_rgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1/6 then return p + (q - p) * 6 * t end
    if t < 1/2 then return q end
    if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
    return p
  end

  local q = l < 0.5 and l * (1 + s) or l + s - l * s
  local p = 2 * l - q

  return {
    r = math.floor(hue_to_rgb(p, q, h + 1/3) * 255),
    g = math.floor(hue_to_rgb(p, q, h) * 255),
    b = math.floor(hue_to_rgb(p, q, h - 1/3) * 255),
  }
end

function M.transform(hex, opts)
  if not hex or hex == "NONE" or hex == "" then
    return hex
  end

  local rgb = M.hex_to_rgb(hex)
  local hsl = M.rgb_to_hsl(rgb)

  if opts.h then
    hsl.h = (hsl.h + opts.h) % 360
    if hsl.h < 0 then hsl.h = hsl.h + 360 end
  end

  if opts.s then
    hsl.s = math.min(1, math.max(0, hsl.s * opts.s))
  end

  if opts.l then
    hsl.l = math.min(1, math.max(0, hsl.l * opts.l))
  end

  return M.rgb_to_hex(M.hsl_to_rgb(hsl))
end

return M
