import std/math
import std/strformat

type
  Point* = ref object
    x*, y*: float

  PointInt* = ref object
    x*, y*: int

  Rect* = ref object
    id*: int
    name*: string
    p0*, p1*, p2*, p3*: Point
    w*, h*, area: float
    pos*: bool

  RectInt* = ref object
    id*: int
    name*: string
    p0*, p1*, p2*, p3*: PointInt
    w*, h*, area*: int
    pos*: bool

  Space* = ref object
    sx*, sy*: float

  SpaceBase* = ref object
    sxl*, sxr*, syt*, syb*: float

  SpaceInt* = ref object
    sx*, sy*: int

  SpaceBaseInt* = ref object
    sxl*, sxr*, syt*, syb*: int

  ValidRect* = ref object
    rect*: RectInt
    lot*: int
    valid*: bool


proc getRectAsTuple*(r: Rect): tuple =
  result = (
    id: r.id, 
    name: r.name, 
    w: r.w, 
    h: r.h, 
    p0x: r.p0.x, p0y: r.p0.y, 
    p1x: r.p1.x, p1y: r.p1.y, 
    p2x: r.p2.x, p2y: r.p2.y, 
    p3x: r.p3.x, p3y: r.p3.y, 
    area: r.area,
    pos: r.pos
  )

proc getRectIntAsTuple*(r: RectInt): tuple =
  result = (
    id: r.id, 
    name: r.name, 
    w: r.w, 
    h: r.h, 
    p0x: r.p0.x, p0y: r.p0.y, 
    p1x: r.p1.x, p1y: r.p1.y, 
    p2x: r.p2.x, p2y: r.p2.y, 
    p3x: r.p3.x, p3y: r.p3.y, 
    area: r.area,
    pos: r.pos
  )

proc getSpace*(arr: seq[float]): Space =
  result = Space(sx: arr[0], sy: arr[1])

proc getSpaceBase*(arr: seq[float]): SpaceBase =
  result = SpaceBase(sxl: arr[0], sxr: arr[1], syt: arr[2], syb: arr[3])

proc getPoint*(x, y: float): Point =
  ## Make point(x, y) with float
  result = Point(x: x, y: y)

proc getPointInt*(x, y: int): PointInt =
  ## Make point(x, y) with integer
  result = PointInt(x: x, y: y)

proc printPoint*(p: Point) =
  ## Print x, y of a point
  echo fmt"x: {p.x}, y: {p.y}"

proc setSeparatorIntoInt*(n: int, sep: char = '_'): string =
  ## Set underscore into integer as each 3 digit
  var 
    x: int = n
    xs: string
    xst, tst: seq[char]
    index: int
  xs = $x
  index = 0
  for i in countdown(xs.high, 0):
    tst.add(xs[i])
    inc index
    if index mod 3 == 0 and i != 0:
      tst.add(sep)
  for i in countdown(tst.high, 0):
    xst.add(tst[i])
  xs = ""
  for i in xst:
    xs = xs & i
  xs

proc printPointInt*(p: PointInt) =
  ## Print point(x, y) with integer
  var 
    x: int = p.x
    xs: string 
    y: int = p.y
    ys: string
  xs = setSeparatorIntoInt(x)
  ys = setSeparatorIntoInt(y)
  echo fmt"x: {xs}, y: {ys}"

proc toUM*(x: float): int =
  ## to mm: float from um: int
  result = int(x * 1000)

proc toMM*(n: int): float =
  ## to um int from mm float
  result = float(n / 1000)

proc toPointUM*(p: Point): PointInt =
  ## to point, um: int from point, mm: float
  result = PointInt(x: toUM(p.x), y: toUm(p.y))

proc toPointMM*(p: PointInt): Point =
  ## to point, mm: float from point, um: int
  result = Point(x: toMM(p.x), y: toMM(p.y))

proc toSpaceUM*(space: Space): SpaceInt =
  ## to space, um: int from space, mm: float
  result = SpaceInt(sx: toUM(space.sx), sy: toUM(space.sy))

proc toSpaceMM*(space: SpaceInt): Space =
  ## to space, mm: float from space, um: int
  result = Space(sx: toMM(space.sx), sy: toMM(space.sy))

proc toSpaceBaseUM*(space: SpaceBase): SpaceBaseInt =
  ## to spacebase, um: int from spacebase, mm: float
  result = SpaceBaseInt(sxl: toUM(space.sxl), sxr: toUM(space.sxr), syt: toUM(space.syt), syb: toUM(space.syb))

proc toSpaceBaseMM*(space: SpaceBaseInt): SpaceBase =
  ## to spacebase, mm : float from spacebase, um: int
  result = SpaceBase(sxl: toMM(space.sxl), sxr: toMM(space.sxr), syt: toMM(space.syt), syb: toMM(space.syb))

proc toRectUM*(rect: Rect): RectInt =
  ## to rectInt from rect
  result = RectInt(
    w: toUM(rect.w), 
    h: toUM(rect.h), 
    p0: toPointUM(rect.p0), 
    p1: toPointUM(rect.p1), 
    p2: toPointUM(rect.p2),
    p3: toPointUM(rect.p3),
    area: toUM(rect.w) * toUM(rect.h),
    id: rect.id,
    name: rect.name,
    pos: rect.pos
  )

proc toRectMM*(rect: RectInt): Rect =
  ## to rect from rectInt
  result = Rect(
    w: toMM(rect.w), 
    h: toMM(rect.h), 
    p0: toPointMM(rect.p0), 
    p1: toPointMM(rect.p1), 
    p2: toPointMM(rect.p2),
    p3: toPointMM(rect.p3),
    area: toMM(rect.w) * toMM(rect.h),
    id: rect.id,
    name: rect.name,
    pos: rect.pos
  )

proc toRectsUM*(rects: seq[Rect]): seq[RectInt] =
  for r in rects:
    result.add(toRectUM(r))
  return result

proc getRect*(w, h: float, p0: Point = Point(x: 0.0, y: 0.0), id: int = 0, name: string = "", pos: bool = true): Rect =
  ## get Rect with float values
  result = Rect(
    w: w,
    h: h,
    p0: p0,
    p1: Point(x: p0.x + w, y: p0.y),
    p2: Point(x: p0.x, y: p0.y + h),
    p3: Point(x: p0.x + w, y: p0.y + h),
    area: w * h,
    id: id,
    name: name,
    pos: pos
  )
  return result

proc getRectInt*(w, h: int, p0: PointInt = PointInt(x: 0, y: 0), id: int = 0, name: string = "", pos: bool = true): RectInt =
  ## get RectInt with integer values
  result = RectInt(
    w: w,
    h: h,
    p0: p0,
    p1: PointInt(x: p0.x + w, y: p0.y),
    p2: PointInt(x: p0.x, y: p0.y + h),
    p3: PointInt(x: p0.x + w, y: p0.y + h),
    area: w * h,
    id: id,
    name: name,
    pos: pos
  )

proc printRect*(r: RectInt) =
  echo fmt"id: {$r.id}, w: {$toMM(r.w)}, h: {$toMM(r.h)}, x0: {$toMM(r.p0.x)}, y0: {$toMM(r.p0.y)}, name: {r.name}"

proc isLocatable*(base, target: RectInt): bool =
  ## check target is locatable in base
  result = (base.w >= target.w and base.h >= target.h)

proc isInclude*(base, target: RectInt): bool =
  ## check target is included in base
  result = (
    base.p0.x <= target.p0.x and
    base.p0.y <= target.p0.y and
    base.p3.x >= target.p3.x and
    base.p3.y >= target.p3.y
  )

proc isOverlap*(base, target: RectInt): bool =
  ## check target is overlap with base
  result = (
    max(base.p0.x, target.p0.x) < min(base.p3.x, target.p3.x) and
    max(base.p0.y, target.p0.y) < min(base.p3.y, target.p3.y)
  )

proc sizeupRectSpaceRT*(rect: RectInt, space: SpaceInt): RectInt =
  result = RectInt(
    w: rect.w + space.sx,
    h: rect.h + space.sy,
    p0: PointInt(x: rect.p0.x, y: rect.p0.y),
    p1: PointInt(x: rect.p1.x + space.sx, y: rect.p1.y),
    p2: PointInt(x: rect.p2.x, y: rect.p2.y + space.sy),
    p3: PointInt(x: rect.p3.x + space.sx, y: rect.p3.y + space.sy),
    area: (rect.w + space.sx) * (rect.h + space.sy),
    id: rect.id,
    name: rect.name,
    pos: rect.pos
  )

proc sizeupRectSpaceLB*(rect: RectInt, space: SpaceInt): RectInt =
  result = RectInt(
    w: rect.w + space.sx,
    h: rect.h + space.sy,
    p0: PointInt(x: rect.p0.x - space.sx, y: rect.p0.y - space.sy),
    p1: PointInt(x: rect.p1.x, y: rect.p1.y - space.sy),
    p2: PointInt(x: rect.p2.x - space.sx, y: rect.p2.y),
    p3: PointInt(x: rect.p3.x, y: rect.p3.y),
    area: (rect.w + space.sx) * (rect.h + space.sy),
    id: rect.id,
    name: rect.name,
    pos: rect.pos
  )

proc sizeupRectSpaceLBRT*(rect: RectInt, space: SpaceInt): RectInt =
  result = RectInt(
    w: rect.w + (2 * space.sx),
    h: rect.h + (2 * space.sy),
    p0: PointInt(x: rect.p0.x - space.sx, y: rect.p0.y - space.sy),
    p1: PointInt(x: rect.p1.x + space.sx, y: rect.p1.y - space.sy),
    p2: PointInt(x: rect.p2.x - space.sx, y: rect.p2.y + space.sy),
    p3: PointInt(x: rect.p3.x + space.sx, y: rect.p3.y + space.sy),
    area: (rect.w + (2 * space.sx)) * (rect.h + (2 * space.sy)),
    id: rect.id,
    name: rect.name,
    pos: rect.pos
  )

proc getRectWithOrigin*(rect: RectInt, point: PointInt): RectInt =
  result = RectInt(
    w: rect.w,
    h: rect.h,
    p0: point,
    p1: PointInt(x: point.x + rect.w, y: point.y),
    p2: PointInt(x: point.x, y: point.y + rect.h),
    p3: PointInt(x: point.x + rect.w, y: point.y + rect.h),
    area: rect.area,
    id: rect.id,
    name: rect.name,
    pos: rect.pos
  )

proc rotateRect*(rect: RectInt): RectInt =
  var 
    trect: tuple = getRectIntAsTuple(rect)
    res: RectInt = new RectInt
  #echo trect
  #echo trect.h
  res.w = trect.h
  res.h = trect.w
  res.p0 = PointInt(x: trect.p0x, y: trect.p0y)
  res.p1 = PointInt(x: trect.p3y, y: trect.p0y)
  res.p2 = PointInt(x: trect.p0x, y: trect.p3x)
  res.p3 = PointInt(x: trect.p3y, y: trect.p3x)
  res.area = trect.area
  res.id = trect.id
  res.name = trect.name
  res.pos = trect.pos
  #printRect(res)
  return res

proc getFourRects*(origin, target: RectInt): seq[RectInt] =
  var
    res: seq[RectInt]
  res.add(getRectWithOrigin(target, origin.p1))
  res.add(getRectWithOrigin(rotateRect(target), origin.p1))
  res.add(getRectWithOrigin(target, origin.p2))
  res.add(getRectWithOrigin(rotateRect(target), origin.p2))
  res

proc getValidRect*(rect: RectInt, lot: int = 0, valid: bool = true): ValidRect =
  result = ValidRect(rect: rect, lot: lot, valid: valid)
  return result

proc getValidRects*(rects: seq[RectInt]): seq[ValidRect] =
  for i, r in rects:
    result.add(getValidRect(r, i))
  return result

proc splitLocatableRects*(base: RectInt, rects: seq[RectInt]): seq[seq[RectInt]] =
  var 
    res: seq[seq[RectInt]]
    locatable: seq[RectInt]
    unlocatable: seq[RectInt]
  for rect in rects:
    if isLocatable(base, rect):
      locatable.add(rect)
    elif isLocatable(base, rotateRect(rect)):
      locatable.add(rect)
    else:
      unlocatable.add(rect)
  res.add(locatable)
  res.add(unlocatable)
  res

proc sortRects*(rects: seq[RectInt], smallOrder: bool = false): seq[RectInt] =
  var 
    selfRects: seq[RectInt] = rects
    temp: RectInt
    index: int
  if smallOrder:
    for i in 0 .. (selfRects.high - 1):
      temp = selfRects[i]
      index = i
      for j in (i + 1) .. selfRects.high:
        if temp.area > selfRects[j].area:
          temp = selfRects[j]
          index = j
      selfRects.delete(index)
      selfRects.insert(temp, i)
  else:
    for i in 0 .. (selfRects.high - 1):
      temp = selfRects[i]
      index = i
      for j in (i + 1) .. selfRects.high:
        if temp.area < selfRects[j].area:
          temp = selfRects[j]
          index = j
      selfRects.delete(index)
      selfRects.insert(temp, i)
  selfRects

proc getBase*(base: seq[float], spaceBase: SpaceBase, p0: Point = Point(x: 0.0, y: 0.0), id: int = 0, name: string = "base"): Rect =
  var sb: SpaceBase = spaceBase
  if base[1] > base[0]:
    result = getRect(w = base[1], h = base[0], p0 = p0, id = id, name = name)
  else:
    result = getRect(w = base[0], h = base[1], p0 = p0, id = id, name = name)
  result.w = result.w - sb.sxl - sb.sxr
  result.h = result.h - sb.syt - sb.syb
  result.p0 = Point(x: result.p0.x + sb.sxl, y: result.p0.y + sb.syb)
  result.p1 = Point(x: result.p1.x - sb.sxr, y: result.p1.y + sb.syb)
  result.p2 = Point(x: result.p2.x + sb.sxl, y: result.p2.y - sb.syt)
  result.p3 = Point(x: result.p3.x - sb.sxr, y: result.p3.y - sb.syt)
  result.area = result.w * result.h
  return result

proc getBaseInt*(base: RectInt, spaceBase: SpaceBaseInt, p0: PointInt = PointInt(x: 0, y: 0), id: int = 0, name: string = "base"): RectInt =
  var sb: SpaceBaseInt = spaceBase
  if base.h > base.w:
    result = getRectInt(w = base.h, h = base.w, p0 = p0, id = id, name = name)
  else:
    result = getRectInt(w = base.w, h = base.h, p0 = p0, id = id, name = name)
  result.w = result.w - sb.sxl - sb.sxr
  result.h = result.h - sb.syt - sb.syb
  result.p0 = PointInt(x: result.p0.x + sb.sxl, y: result.p0.y + sb.syb)
  result.p1 = PointInt(x: result.p1.x - sb.sxr, y: result.p1.y + sb.syb)
  result.p2 = PointInt(x: result.p2.x + sb.sxl, y: result.p2.y - sb.syt)
  result.p3 = PointInt(x: result.p3.x - sb.sxr, y: result.p3.y - sb.syt)
  result.area = result.w * result.h
  return result

proc getRects*(arr: seq[seq[float]]): seq[RectInt] =
  var selfRects: seq[RectInt]
  for i, s in arr:
    selfRects.add(getRectInt(w = toUM(s[0]), h = toUM(s[1]), id = i))
  selfRects

proc printAreas*(rects: seq[RectInt]) =
  for r in rects:
    echo fmt"w: {setSeparatorIntoInt(r.w)}, h: {setSeparatorIntoInt(r.h)}, p0.x: {setSeparatorIntoInt(r.p0.x)}, p0.y: {setSeparatorIntoInt(r.p0.y)}, area: {setSeparatorIntoInt(r.area)}"

proc getFirstLocated*(base, target: RectInt): seq[RectInt] =
  result = @[]
  if isLocatable(base, target):
    result.add(getRectWithOrigin(target, base.p0))
  elif isLocatable(base, rotateRect(target)):
    result.add(getRectWithOrigin(rotateRect(target), base.p0))
  else:
    var msg: string = "The target rectangle w: " & $toMM(target.w) & ", h: " & $toMM(target.h) & "is larger than base rectangle"
    echo msg
  return result

proc getCandidates*(base, target: RectInt, locatedRects: seq[RectInt], space: SpaceInt): seq[ValidRect] =
  ## return candidates(rectangles) which locatable
  var
    temp: RectInt
    res: seq[ValidRect]
  for i, r in locatedRects:
    temp = sizeupRectSpaceRT(r, space)
    for t in getFourRects(temp, target):
      res.add(getValidRect(t, i, true))
  res

proc getSameValid*(rects: seq[ValidRect], lot: int): seq[ValidRect] =
  for r in rects:
    if r.lot == lot: result.add(r)
  return result

proc delSameValid*(rects: seq[ValidRect], lot: int): seq[ValidRect] =
  for r in rects:
    if r.lot != lot: result.add(r)
  return result

proc getTrueValid*(rects: seq[ValidRect]): seq[ValidRect] =
  for r in rects:
    if r.valid: result.add(r)
  return result

proc toInvalid*(rect: ValidRect, lot: int): ValidRect =
  result = rect
  if result.lot == lot:
    if result.valid: result.valid = false
  return result

proc getLocatables*(base: RectInt, locatedRects: seq[RectInt], candidates: seq[ValidRect], space: SpaceInt): seq[ValidRect] =
  ## check locatable candidates as valid = true of ValidRect
  var
    can: seq[ValidRect] = candidates
    temp: RectInt
  for c in can:
    if not isInclude(base, c.rect): c.valid = false
  for r in locatedRects:
    temp = sizeupRectSpaceLBRT(r, space)
    for c in can:
      if isOverlap(temp, c.rect): c.valid = false
  can

proc getAngle*(target: RectInt): float =
  result = arctan(target.p1.y / target.p1.x)

proc sortAngle*(rects: seq[RectInt]): seq[RectInt] =
  var 
    selfRects: seq[RectInt] = rects
    temp: RectInt
    index: int
    rad: float
  for i in 0 .. (selfRects.high - 1):
    rad = getAngle(selfRects[i])
    index = i
    for j in (i + 1) .. selfRects.high:
      if getAngle(selfRects[j]) < rad: 
        rad = getAngle(selfRects[j])
        temp = selfRects[j]
        index = j
    selfRects.delete(index)
    selfRects.insert(temp, i)
  selfRects

proc getLocatedRects*(base: RectInt, seqRects: seq[seq[RectInt]], space: SpaceInt): seq[seq[RectInt]] =
  var
    rects: seq[RectInt] = seqRects[0]
    locatedRects: seq[RectInt] = @[]
    target: RectInt
    can: seq[ValidRect]
    rad: float = 3.15 / 2
    radA: float
    onceValid, pastValid: bool
    allInvalid: bool = false
    i, index, lot: int
  while true:
    index = 0
    pastValid = false
    if allInvalid: break
    while true:
      if i > rects.high: break
      can = getCandidates(base, rects[i], locatedRects, space)
      can = getLocatables(base, locatedRects, can, space)
      #echo "======================="
      #for c in can:
      #  if c.valid: printRect(c.rect)
      #echo "======================="
      onceValid = false
      if can.len > 0:
        for c in can:
          lot = -1
          if c.valid: 
            radA = getAngle(c.rect)
            if radA < rad: 
              rad = radA
              lot = c.lot
              target = c.rect
              index = i
              onceValid = true
              pastValid = true
        if lot >= 0:
          for c in can:
            if c.lot == lot: c.valid = false
      #echo "## Result ##"
      #printRect(result)
      if onceValid:
        rects.delete(index)
        locatedRects.add(target)
        index = 0
      inc i
    if not pastValid: allInvalid = true
  result = seqRects
  result[0] = rects
  result.add(locatedRects)

proc isDifferentRects*(base, target: RectInt): bool =
  if target == nil: 
    result = false
  else:
    if base.pos == target.pos:
      if base.w != target.w or
        base.h != target.h or
        base.p0.x != target.p0.x or
        base.p0.y != target.p0.y: result = true
      else: result = false
    else:
      if base.w != target.h or
        base.h != target.w or
        base.p0.x != target.p0.x or
        base.p0.y != target.p0.y: result = true
      else: result = false

proc isSameSizeRects*(base, target: RectInt): bool =
  if base == nil:
    result = false
    return result
  if target == nil:
    result = false
    return result
  if base.pos == target.pos:
    if base.w == target.w and base.h == target.h: result = true
    else: result = false
  else:
    if base.w == target.h and base.h == target.w: result = true
    else: result = false
      
proc printRects*(rects: seq[RectInt]) =
  echo "========================================================================================================="
  for r in rects:
    echo fmt"id: {$r.id}, w: {$toMM(r.w)}, h: {$toMM(r.h)}, ox: {$toMM(r.p0.x)}, oy: {$toMM(r.p0.y)}, name: {r.name}"

proc delRects*(rects, targets: seq[RectInt]): seq[RectInt] =
  var 
    selfRects = rects
    selfTargets = targets
    rfin: int = rects.len - 1
    tfin: int = targets.len - 1
    i, j: int
  i = rfin
  j = tfin
  #echo "^^^ rects ^^^^^^^^^^^^^^^"
  #printRects(selfRects)
  #echo "^^^^^^^^^^^^^^^^^^^^^^^^^"
  while true:
    if rfin < 0: break
    tfin = selfTargets.len - 1 
    while true:
      if tfin < 0: break
      if isSameSizeRects(selfRects[rfin], selfTargets[tfin]):
        selfRects.delete(rfin)
        selfTargets.delete(tfin)
        #echo "--- Rects -------------"
        #printRects(selfRects)
        #echo "--- Located Rects -----"
        #printRects(selfTargets)
        break
      dec tfin
    dec rfin
  selfRects

proc toValidRects*(rects: seq[RectInt]): seq[ValidRect] =
  for i, r in rects:
    result.add(ValidRect(rect: r, lot: i, valid: true))
  return result

proc isEmpty*(vRects: seq[ValidRect]): bool =
  var flgEmpty: bool = true
  for vr in vRects:
    if vr.valid: flgEmpty = false
  return flgEmpty

proc getAllRects*(base: RectInt, rects: seq[Rect], space: SpaceInt, spaceBaseInt: SpaceBaseInt): seq[seq[RectInt]] =
  ## return all of located rects as @[@[all rects], @[unlocatedbrects], @[located rects#1], @[located rects#2], ...]
  var
    vRects, can: seq[ValidRect]
    rectsInt, locatedRects, tempLocated: seq[RectInt]
    baseInt: RectInt

    #unlocatedRects: seq[RectInt]
    #locatedRects: seq[RectInt]
    res: seq[seq[RectInt]]
  baseInt = getBaseInt(base, spaceBaseInt)
  rectsInt = toRectsUM(rects)
  res = splitLocatableRects(baseInt, rectsInt)
  res[0] = sortRects(res[0], false)
  vRects = toValidRects(res[0])
  #unlocatedRects = res[1]

  while true:
    if isEmpty(vRects): break
    locatedRects = @[]
    tempLocated = @[]
    for i, vr in vRects:
      if vr.valid:
        if locatedRects.len == 0:
          locatedRects.add(getFirstLocated(baseInt, vr.rect))
          tempLocated = locatedRects
          vRects[i].valid = false
        else:
          for origin in tempLocated:
            can = getCandidates(origin, vr.rect, locatedRects, space)
          for origin in tempLocated:
            can = getLocatables(baseInt, locatedRects, can, space)
          for c in can:
            if c.valid:
              locatedRects.add(c.rect)
              tempLocated = sortAngle(locatedRects)
              vRects[i].valid = false
              break
          can = @[]
    res.add(locatedRects)
            
    ##########################################################################################################################

    #locatedRects = @[]

    #if locatedRects.len ==  0: break
    #echo repr locatedRects
    #echo res.len
    #selfRects = delRects(selfRects, locatedRects)
    #echo selfRects.len
  res


proc test*() =
  var rect = getRectInt(w = 1000000, h = 2000000)
  echo "1", repr rect
  var res = rotateRect(rect)
  echo "2", repr res
  echo "3", repr rect

