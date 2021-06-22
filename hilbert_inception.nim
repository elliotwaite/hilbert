import common, pixie

const
  pixelScale = 4.0
  outerIteration = 3
  innerIteration = 3
  fromCorner = vec2(-1, -1)
  toCorner = vec2(1, -1)
  colorSeq = allSaturatedColors()
  pixelsPerColorCycle = 16255
  colorSpeed = colorSeq.len.float / pixelsPerColorCycle.float

proc toColor(dist: int): ColorRGBA =
  colorSeq[(dist.float * colorSpeed).int mod colorSeq.len]

proc hilbertSize(outerIteration, innerIteration: int): float =
  if outerIteration == 0:
    if innerIteration == 0:
      1.0
    else:
      hilbertSize(0, innerIteration - 1) +
      1.0 +
      hilbertSize(0, innerIteration - 1)
  else:
    hilbertSize(outerIteration - 1, innerIteration) +
    1.0 +
    hilbertSize(0, innerIteration) +
    1.0 +
    hilbertSize(outerIteration - 1, innerIteration)

proc drawInnerHilbert(
  ctx: Context,
  pos: Vec2,
  fromCorner: Vec2,
  toCorner: Vec2,
  iteration: int,
  dist: var int
) =
  if iteration == 0:
    ctx.addPixel(pos, dist.toColor, pixelScale)
    dist += 1
  else:
    var pos = pos
    let size = hilbertSize(0, iteration - 1)
    let dir1 = (-toCorner - fromCorner) / 2.0
    let dir2 = (toCorner - fromCorner) / 2.0
    let dir3 = (fromCorner + toCorner) / 2.0

    ctx.drawInnerHilbert(pos, fromCorner, -toCorner, iteration - 1, dist)
    pos += dir1 * size

    ctx.addPixel(pos, dist.toColor, pixelScale)
    dist += 1
    pos += dir1

    ctx.drawInnerHilbert(pos, fromCorner, toCorner, iteration - 1, dist)
    pos += dir2 * size

    ctx.addPixel(pos, dist.toColor, pixelScale)
    dist += 1
    pos += dir2

    ctx.drawInnerHilbert(pos, fromCorner, toCorner, iteration - 1, dist)
    pos += dir2 * (size - 1) + dir3

    ctx.addPixel(pos, dist.toColor, pixelScale)
    dist += 1
    pos += dir3

    ctx.drawInnerHilbert(pos, -fromCorner, toCorner, iteration - 1, dist)

proc drawOuterHilbert(
  ctx: Context,
  pos: Vec2,
  fromCorner: Vec2,
  toCorner: Vec2,
  outerIteration: int,
  innerIteration: int,
  dist: var int
) =
  if outerIteration == 0:
    ctx.drawInnerHilbert(pos, fromCorner, toCorner, innerIteration, dist)
  else:
    var pos = pos
    let outerSize = hilbertSize(outerIteration - 1, innerIteration)
    let innerSize = hilbertSize(0, innerIteration)
    let dir1 = (-toCorner - fromCorner) / 2.0
    let dir2 = (toCorner - fromCorner) / 2.0
    let dir3 = (fromCorner + toCorner) / 2.0

    # Quadrant 1
    ctx.drawOuterHilbert(pos, fromCorner, -toCorner, outerIteration - 1, innerIteration, dist)
    pos += dir1 * outerSize

    # Connect 1 to 2
    ctx.addPixel(pos, dist.toColor, pixelScale)
    dist += 1
    pos += dir1

    ctx.drawInnerHilbert(pos, fromCorner, -toCorner, innerIteration, dist)
    pos += dir1 * innerSize

    ctx.addPixel(pos, dist.toColor, pixelScale)
    dist += 1
    pos += dir1

    # Quadrant 2
    ctx.drawOuterHilbert(pos, fromCorner, toCorner, outerIteration - 1, innerIteration, dist)
    pos += dir2 * outerSize

    # Connect 2 to 3
    ctx.addPixel(pos, dist.toColor, pixelScale)
    dist += 1
    pos += dir2

    ctx.drawInnerHilbert(pos, fromCorner, toCorner, innerIteration, dist)
    pos += dir2 * innerSize

    ctx.addPixel(pos, dist.toColor, pixelScale)
    dist += 1
    pos += dir2

    # Quadrant 3
    ctx.drawOuterHilbert(pos, fromCorner, toCorner, outerIteration - 1, innerIteration, dist)
    pos += dir2 * (outerSize - 1) + dir3

    # Connect 3 to 4
    ctx.addPixel(pos, dist.toColor, pixelScale)
    dist += 1
    pos += dir3

    ctx.drawInnerHilbert(pos, -fromCorner, toCorner, innerIteration, dist)
    pos += dir3 * innerSize

    ctx.addPixel(pos, dist.toColor, pixelScale)
    dist += 1
    pos += dir3

    # Quadrant 4
    ctx.drawOuterHilbert(pos, -fromCorner, toCorner, outerIteration - 1, innerIteration, dist)

proc main() =
  let imagePadding = 2.0 + hilbertSize(0, innerIteration)
  let startPos = vec2(imagePadding, imagePadding)
  let imageSize = 2.0 * imagePadding + hilbertSize(outerIteration, innerIteration)
  let image = newImage((imageSize * pixelScale).int, (imageSize * pixelScale).int)
  image.fill(rgba(0, 0, 0, 255))

  var dist: int
  let ctx = newContext(image)
  ctx.drawOuterHilbert(startPos, fromCorner, toCorner, outerIteration, innerIteration, dist)
  echo "Pixels drawn: " & $dist

  image.writeFile("hilbert_inception.png")

main()
