import common, pixie

const
  iteration = 8
  startPos = vec2(1, 1)
  fromCorner = vec2(-1, -1)
  toCorner = vec2(1, -1)
  colorSeq = allSaturatedColors()
  colorSpeed = 1.0

proc toColor(dist: int): ColorRGBA =
  colorSeq[(dist.float * colorSpeed).int mod colorSeq.len]

proc hilbertSize(iteration: int): float =
  if iteration == 0:
    1.0
  else:
    2.0 * hilbertSize(iteration - 1) + 1.0

proc drawHilbert(
  ctx: Context,
  pos: Vec2,
  fromCorner: Vec2,
  toCorner: Vec2,
  iteration: int,
  dist: var int
) =
  if iteration == 0:
    ctx.addPixel(pos, dist.toColor)
    dist += 1
  else:
    var pos = pos
    let size = hilbertSize(iteration - 1)
    let dir1 = (-toCorner - fromCorner) / 2.0
    let dir2 = (toCorner - fromCorner) / 2.0
    let dir3 = (fromCorner + toCorner) / 2.0

    ctx.drawHilbert(pos, fromCorner, -toCorner, iteration - 1, dist)
    pos += dir1 * size

    ctx.addPixel(pos, dist.toColor)
    dist += 1
    pos += dir1

    ctx.drawHilbert(pos, fromCorner, toCorner, iteration - 1, dist)
    pos += dir2 * size

    ctx.addPixel(pos, dist.toColor)
    dist += 1
    pos += dir2

    ctx.drawHilbert(pos, fromCorner, toCorner, iteration - 1, dist)
    pos += dir2 * (size - 1) + dir3

    ctx.addPixel(pos, dist.toColor)
    dist += 1
    pos += dir3

    ctx.drawHilbert(pos, -fromCorner, toCorner, iteration - 1, dist)

proc main() =
  let imageSize = 2 + hilbertSize(iteration)
  let image = newImage(imageSize.int, imageSize.int)
  image.fill(rgba(0, 0, 0, 255))

  var dist: int
  let ctx = newContext(image)
  ctx.drawHilbert(startPos, fromCorner, toCorner, iteration, dist)
  echo "Pixels drawn: " & $dist

  image.writeFile("hilbert_rainbow.png")

main()
