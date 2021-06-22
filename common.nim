import pixie

proc addPixel*(ctx: Context, pos: Vec2, color: ColorRGBA, pixelScale = 1.0) =
  ctx.fillStyle = color
  ctx.fillRect(rect(vec2(pos.x * pixelScale, pos.y * pixelScale), vec2(pixelScale, pixelScale)))

proc allSaturatedColors*(): seq[ColorRGBA] =
  for g in 0'u8 .. 254'u8:
    result.add(rgba(255, g, 0, 255))
  for r in countdown(255'u8, 1'u8):
    result.add(rgba(r, 255, 0, 255))

  for b in 0'u8 .. 254'u8:
    result.add(rgba(0, 255, b, 255))
  for g in countdown(255'u8, 1'u8):
    result.add(rgba(0, g, 255, 255))

  for r in 0'u8 .. 254'u8:
    result.add(rgba(r, 0, 255, 255))
  for b in countdown(255'u8, 1'u8):
    result.add(rgba(255, 0, b, 255))
