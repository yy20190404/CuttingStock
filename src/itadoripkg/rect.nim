# submodule of Itadori, for easy use of rectangle objects
import strformat

type 
  Point* = object
    # Pointオブジェクト: x,y: int
    x*, y*: float

  PointInt* = object
    # Pointオブジェクト: x,y: int
    x*, y*: int

  Rect* = object
    # 長方形オブジェクト　4つの頂点の配列pkと幅w,高さh
    name*: string
    p0*: Point
    p1*: Point
    p2*: Point
    p3*: Point
    w*, h*: float
    pos*: bool # positive position: true, rotated position: flase
    index*: int # the order added in array

  RectInt* = object
    # 長方形オブジェクト　4つの頂点の配列pkと幅w,高さh
    name*: string
    p0*: PointInt
    p1*: PointInt
    p2*: PointInt
    p3*: PointInt
    w*, h*: int
    pos*: bool # positive position: true, rotated position: flase
    index*: int # the order added in array

  Space* = object
    # Space between rectangles: sx, sy: float
    sx*, sy*: float

  SpaceInt* = object
    # Space between rectangles: sx, sy: integer
    sx*, sy*: int

  SpaceBase* = object
    # Edge spaces of base rectangle: sxl, sxr, syb, syt: float
    sxl*, sxr*, syb*, syt*: float

  SpaceBaseInt* = object
    # Edge spaces of base rectangle: sxl, sxr, syb, syt: int
    sxl*, sxr*, syb*, syt*: int


proc toUMint*(f: float): int =
  return int(f * 1000)

proc toMMfloat*(i: int): float =
  return float(i / 1000)

proc toUMpoint*(p: Point): PointInt =
  var ret: PointInt
  ret.x = int(p.x * 1000)
  ret.y = int(p.y * 1000)
  ret

proc toMMpoint*(p: PointInt): Point =
  var ret: Point
  ret.x = float(p.x / 1000)
  ret.y = float(p.y / 1000)
  ret

proc toUMspace*(s: Space): SpaceInt =
  var ret: SpaceInt
  ret.sx = int(s.sx * 1000)
  ret.sy = int(s.sy * 1000)
  ret

proc toMMspcae*(s: SpaceInt): Space =
  var ret: Space
  ret.sx = float(s.sx / 1000)
  ret.sy = float(s.sy / 1000)
  ret

proc toUMspaceBase*(s: SpaceBase): SpaceBaseInt =
  var 
    ret: SpaceBaseInt
  ret.sxl = int(s.sxl * 1000)
  ret.sxr = int(s.sxr * 1000)
  ret.syb = int(s.syb * 1000)
  ret.syt = int(s.syt * 1000)
  ret

proc toMMspcaeBase*(s: SpaceBaseInt): SpaceBase =
  var ret: SpaceBase
  ret.sxl = float(s.sxl / 1000)
  ret.sxr = float(s.sxr / 1000)
  ret.syb = float(s.syb / 1000)
  ret.syt = float(s.syt / 1000)
  ret

proc toUMrect*(r: Rect): RectInt =
  var ret: RectInt
  ret.w = int(r.w * 1000)
  ret.h = int(r.h * 1000)
  ret.p0 = toUMpoint(r.p0)
  ret.p1 = toUMpoint(r.p1)
  ret.p2 = toUMpoint(r.p2)
  ret.p3 = toUMpoint(r.p3)
  ret.index = r.index
  ret.pos = r.pos
  ret.name = r.name
  ret

proc toMMrect*(r: RectInt): Rect =
  var ret: Rect
  ret.w = float(r.w / 1000)
  ret.h = float(r.h / 1000)
  ret.p0 = toMMpoint(r.p0)
  ret.p1 = toMMpoint(r.p1)
  ret.p2 = toMMpoint(r.p2)
  ret.p3 = toMMpoint(r.p3)
  ret.index = r.index
  ret.pos = r.pos
  ret.name = r.name
  ret



proc reverse*[T](arr: seq[T]): seq[T] =
  # Reverse array
  var ans: seq[T]
  for i in countdown(arr.high, arr.low):
    ans.add(arr[i])
  ans

proc sort*[T](arr: seq[T], flag: bool = true): seq[T] =
  # ソート　小さい順flag=true, 大きい順flag=false
  var 
    self_arr: seq[T] = arr
    a, b: T
    index: int
  for i in 0..selfArr.high:
    index = i
    a = self_arr[i]
    for j in i+1..selfArr.high:
      b = self_arr[j]
      if b < a:
        a = b
        index = j
    self_arr.delete(index)
    self_arr.insert(a, i)
  if flag == false: selfArr = reverse(selfArr)
  self_arr

proc sortRect*(rects: var seq[RectInt], flag: bool = false): seq[RectInt] =
  # rectsをソートする　flag=trueで小さい順　flag=falseで大きい順
  let length = len(rects)
  var 
    area1, area2: int
    j, index: int
    target: RectInt
  for i, ri in rects:
    area1 = ri.w * ri.h
    target = ri
    index = i
    j = i + 1
    while j < length:
      area2 = rects[j].w * rects[i].h
      if flag:
        if area2 < area1:
          target = rects[j]
          index = j
          area1 = area2
      else:
        if area2 > area1:
          target = rects[j]
          index = j
          area1 = area2
      inc j
    rects.delete(index)
    rects.insert(target, i)
  rects

proc sortRectWithIndex*(rects: seq[RectInt]): seq[RectInt] =
  # rectsをソートする　rect.index の小さい順に整列
  var length = rects.len
  var selfRects: seq[RectInt]
  var temp: RectInt
  for i in 0..<length:
    temp = rects[i]
    for j in (i + 1)..<length:
      if temp.index > rects[j].index:
        temp = rects[j]
        temp.index = i
    selfRects.add(temp)
  selfRects

proc makeRect*(w, h: float, x = 0.0, y = 0.0, name = "no name", index = 0): Rect =
  # 長方形四隅の点座標をまとめたpkと幅w、高さhで長方形オブジェクトを作成
  let 
    xe: float = x + w
    ye: float = y + h
    pos: bool = true
  var 
    p0, p1, p2, p3: Point
    r: Rect
  p0 = Point(x: x, y: y)
  p1 = Point(x: xe, y: y)
  p2 = Point(x: x, y: ye)
  p3 = Point(x: xe, y: ye)
  r = Rect(p0: p0, p1: p1, p2: p2, p3: p3, w: w, h: h, name: name, pos: pos, index: index)
  r

proc makeRectInt*(w, h: int, x = 0, y = 0, name = "no name", index = 0): RectInt =
  # 長方形四隅の点座標をまとめたpkと幅w、高さhで長方形オブジェクトを作成
  let 
    xe: int = x + w
    ye: int = y + h
    pos: bool = true
  var 
    p0, p1, p2, p3: PointInt
    r: RectInt
  p0 = PointInt(x: x, y: y)
  p1 = PointInt(x: xe, y: y)
  p2 = PointInt(x: x, y: ye)
  p3 = PointInt(x: xe, y: ye)
  r = RectInt(p0: p0, p1: p1, p2: p2, p3: p3, w: w, h: h, name: name, pos: pos, index: index)
  r

proc rotateRect*(r: RectInt): RectInt =
  # Rotate rectangle 90 degree
  var selfRect: RectInt = r
  var t: int
  t = selfRect.p3.x
  selfRect.p3.x = selfRect.p3.y
  selfRect.p3.y= t
  selfRect.p1.x = selfRect.p3.x
  selfRect.p2.y = selfRect.p3.y
  t = selfRect.w
  selfRect.w = selfRect.h
  selfRect.h = t
  selfRect.pos = not r.pos
  selfRect

proc makeRectWithSpace*(rect: RectInt, s: SpaceInt): RectInt =
  # 長方形にスペース分を足した長方形オブジェクトを返す
  var 
    selfRect: RectInt = rect
    selfSpace: SpaceInt = s

  #selfRect.p0.x = selfRect.p0.x
  #selfRect.p0.y = selfRect.p0.y
  selfRect.p1.x = selfRect.p1.x + selfSpace.sx
  #selfRect.p1.y = selfRect.p1.y
  #selfRect.p2.x = selfRect.p2.x
  selfRect.p2.y = selfRect.p2.y + selfSpace.sy
  selfRect.p3.x = selfRect.p3.x + selfSpace.sx
  selfRect.p3.y = selfRect.p3.y + selfSpace.sy
  selfRect.w = selfRect.w + selfSpace.sx
  selfRect.h = selfRect.h + selfSpace.sy
  selfRect

proc makeRectAddLowSpace*(rect: RectInt, s: SpaceInt): RectInt =
  # 長方形にスペース分を足した長方形オブジェクトを返す
  var 
    selfRect: RectInt = rect
    selfSpace: SpaceInt = s
  selfRect.p0.x = selfRect.p0.x - selfSpace.sx
  selfRect.p0.y = selfRect.p0.y - selfSpace.sy
  #selfRect.p1.x = selfRect.p1.x
  selfRect.p1.y = selfRect.p1.y - selfSpace.sy
  selfRect.p2.x = selfRect.p2.x - selfSpace.sx
  #selfRect.p2.y = selfRect.p2.y
  #selfRect.p3.x = selfRect.p3.x
  #selfRect.p3.y = selfRect.p3.y
  selfRect.w = selfRect.w + selfSpace.sx
  selfRect.h = selfRect.h + selfSpace.sy
  selfRect

proc remakeRectWithOrigin*(rect: RectInt, p: PointInt): RectInt =
  # rectに始点pにしてrectを返す
  var 
    selfRect: RectInt = rect
    selfPoint: PointInt = p
  selfRect.p0 = selfPoint
  selfRect.p1 = PointInt(x: selfPoint.x + selfRect.w, y: selfPoint.y)
  selfRect.p2 = PointInt(x: selfPoint.x, y: selfPoint.y + selfRect.h)
  selfRect.p3 = PointInt(x: selfPoint.x + selfRect.w, y: selfPoint.y + selfRect.h)
  #echo "selfRect: ", selfRect
  selfRect

proc makeBaseWithoutSpace*(base: RectInt, s: SpaceBaseInt): RectInt =
  # ベース長方形の周辺部スペースを削除した配置可能なサイズの長方形オブジェクトを返す
  var 
    selfRect: RectInt = base
    selfSpaceBase: SpaceBaseInt = s
  selfRect.p0.x = selfRect.p0.x + selfSpaceBase.sxl
  selfRect.p0.y = selfRect.p0.y + selfSpaceBase.syb
  selfRect.p1.x = selfRect.p1.x - selfSpaceBase.sxr
  selfRect.p1.y = selfRect.p1.y + selfSpaceBase.syb
  selfRect.p2.x = selfRect.p2.x + selfSpaceBase.sxl
  selfRect.p2.y = selfRect.p2.y - selfSpaceBase.syt
  selfRect.p3.x = selfRect.p3.x - selfSpaceBase.sxr
  selfRect.p3.y = selfRect.p3.y - selfSpaceBase.syt
  selfRect.w = selfRect.w - selfSpaceBase.sxl - selfSpaceBase.sxr
  selfRect.h = selfRect.h - selfSpaceBase.syb - selfSpaceBase.syt
  selfRect

#[
proc arrToRects*(arrSeq: seq[seq[float]]): seq[Rect] =
    # rectangles:seq[seq[int]]をrects:seq[Rect]に変換(各長方形の原点はX:0,y:0)
    var 
      w, h: float
      rect: Rect
      rects: seq[Rect]
    for each in arrSeq:
        w = each[0]
        h = each[1]
        rect = makeRect(w = w, h = h)
        rects.add(rect)
    rects
]#

proc echoRects*(rects: seq[Rect]) =
  var i = 1
  for rect in rects:
    echo fmt"""Rect No.{i}:
    p0(x, y): ({rect.p0.x}, {rect.p0.y}) 
    p1(x, y): ({rect.p1.x}, {rect.p1.y}) 
    p2(x, y): ({rect.p2.x}, {rect.p2.y}) 
    p3(x, y): ({rect.p3.x}, {rect.p3.y}) 
    width: {rect.w} mm
    height: {rect.h} mm"""
    inc i
  discard

proc isLocatable*(rb, ri: RectInt): bool =
  # 長方形rbに長方形riがサイズ上含まれるか判定
  #echo (rb.w >= ri.w and rb.h >= ri.h and ri.w > 0 and ri.h > 0)
  (rb.w >= ri.w and rb.h >= ri.h and ri.w > 0 and ri.h > 0)

proc isInclude*(rb, ri: RectInt): bool =
  # 長方形rbに長方形riが座標上含まれるか判定
  var 
    selfRb = rb
    selfRi = ri
  (selfRb.p0.x <= selfRi.p0.x and selfRb.p1.x >= selfRi.p1.x and
    selfRb.p0.y <= selfRi.p0.y and selfRb.p2.y >= selfRi.p2.y)

proc isSame*(rb, ri: RectInt): bool =
  # 長方形rbと長方形riが重なっているか判定
  var 
    selfRb = rb
    selfRi = ri
  var flag: bool = false
  var bmin, bmax, imin, imax: PointInt
  bmin = selfRb.p0
  bmax = selfRb.p3
  imin = selfRi.p0
  imax = selfRi.p3
  if bmin == imin and bmax == imax: flag = true
  flag

proc isOverlap*(rb, ri: RectInt): bool =
  # 長方形rbと長方形riが重なっているか判定
  var 
    selfRb = rb
    selfRi = ri
  var flag: bool = false
  var x1, x2, x3, x4, y1, y2, y3, y4: int
  x1 = selfRb.p0.x
  x2 = selfRb.p3.x
  y1 = selfRb.p0.y
  y2 = selfRb.p3.y
  x3 = selfRi.p0.x
  x4 = selfRi.p3.x
  y3 = selfRi.p0.y
  y4 = selfRi.p3.y
  if (max(x1, x3) < min(x2, x4)) and (max(y1, y3) < min(y2, y4)): flag = true
  flag

proc makeBase*(baseSizeInt: seq[int], spaceBaseInt: SpaceBaseInt): RectInt =
  # ベース長方形の作成
  # 3x6:   914x1829mm
  # 4x8:  1219x2438mm
  # 5x10: 1524x3048mm
  var baseInt: RectInt
  baseInt = makeRectInt(baseSizeInt[0], baseSizeInt[1])
  baseInt = makeBaseWithoutSpace(baseInt, spaceBaseInt)
  baseInt                                                                                 

proc getLocatableRects*(base: RectInt, rects: seq[RectInt]): seq[seq[RectInt]] =
  # Return locatable rectangles only
  var okey: seq[RectInt]
  var ng: seq[RectInt]
  okey = @[]
  ng = @[]
  var ansSeq: seq[seq[RectInt]]
  for r in rects:
    if isLocatable(base, r):
      okey.add(r)
    elif isLocatable(base, rotateRect(r)):
      okey.add(rotateRect(r))
    else:
      ng.add(r)
  ansSeq = @[okey, ng]
  ansSeq

proc compareVertical*(rect1, rect2: RectInt, peak: string): RectInt =
  var ret: Rectint
  if peak == "p0":
    if rect1.p0.y <= rect2.p0.y: ret = rect1 else: ret = rect2
  elif peak == "p1":
    if rect1.p1.y <= rect2.p1.y: ret = rect1 else: ret = rect2
  elif peak == "p2":
    if rect1.p2.y <= rect2.p2.y: ret = rect1 else: ret = rect2
  else:
    if rect1.p3.y <= rect2.p3.y: ret = rect1 else: ret = rect2
  ret

proc compareHolizontal*(rect1, rect2: RectInt, peak: string): RectInt =
  var ret: Rectint
  if peak == "p0":
    if rect1.p0.x <= rect2.p0.x: ret = rect1 else: ret = rect2
  elif peak == "p1":
    if rect1.p1.x <= rect2.p1.x: ret = rect1 else: ret = rect2
  elif peak == "p2":
    if rect1.p2.x <= rect2.p2.x: ret = rect1 else: ret = rect2
  else:
    if rect1.p3.x <= rect2.p3.x: ret = rect1 else: ret = rect2
  ret

proc comparePeak*(rect1, rect2: RectInt): RectInt =
  var ret: RectInt
  if rect1.p0.y == rect2.p0.y: 
    ret = compareHolizontal(rect1, rect2, "p1")
  elif rect1.p0.y < rect2.p0.y:
    ret = rect1
  else:
    ret = rect2
  ret

proc selectRect*(base: RectInt, rects: seq[RectInt]): RectInt =
  var ret: RectInt
  if rects.len == 0: ret = base
  elif rects.len == 1: ret = rects[0]
  elif rects.len == 2: ret = comparePeak(rects[0], rects[1])
  elif rects.len == 3:
    ret = comparePeak(rects[0], rects[1])
    ret = comparePeak(ret, rects[2])
  else:
    ret = comparePeak(rects[0], rects[1])
    ret = comparePeak(ret, rects[2])
    ret = comparePeak(ret, rects[3])
  ret

proc isDifferentToBase*(base, rect: RectInt): bool =
  var ret: bool = true
  if base.w == rect.w and
    base.h == rect.h and
    base.p0.x == rect.p0.x and
    base.p0.y == rect.p0.y:
      ret = false
  ret

proc locateRect*(base: RectInt, target: RectInt, locatedRects: seq[RectInt], space: SpaceInt): RectInt =
  # Locate target onto base
  var
    rectArray: array[4, RectInt]
    rectArrayTemp: seq[RectInt] = @[]
    flagArray: array[4, bool]= [false, false, false, false]
    ret, firstRect1, firstRect2: RectInt

  if locatedRects.len == 0:
    # First location of rectangle onto base
    firstRect1 = target
    firstRect2 = rotateRect(target)
    if isLocatable(base, firstRect1) and isLocatable(base, firstRect2) and firstRect2.w < firstRect1.w: ret = remakeRectWithOrigin(firstRect2, base.p0)
    elif islocatable(base, firstRect2) and firstRect2.w < firstRect1.w: ret = remakeRectWithOrigin(firstRect2, base.p0)
    elif isLocatable(base, firstRect1): ret = remakeRectWithOrigin(firstRect1, base.p0)
    else: ret = base
    return ret
  
  else:
    # Over second location
    rectArrayTemp = @[]
    for rect in locatedRects:
      # Select one location
      rectArray = [
        remakeRectWithOrigin(target, makeRectWithSpace(rect, space).p1),
        remakeRectWithOrigin(target, makeRectWithSpace(rect, space).p2),
        remakeRectWithOrigin(rotateRect(target), makeRectWithSpace(rect, space).p1),
        remakeRectWithOrigin(rotateRect(target), makeRectWithSpace(rect, space).p2)
      ] 
      # Make four rectangles with 

      for i in 0..3: 
        # Check location possibility of four rectangles
        if isInclude(base, rectArray[i]): flagArray[i] = true else: flagArray[i] = false
      for rect2 in locatedRects:
        # Select all locatable rectangles from four rectangles
        for i in 0..3: 
          if isOverlap(makeRectAddLowSpace(makeRectWithSpace(rect2, space), space), rectArray[i]): flagArray[i] = false
      
      for i in 0..3: 
        # collect all locatable rectangles
        if flagArray[i]: rectArrayTemp.add(rectArray[i])

    if rectArrayTemp.len == 0: # select one rectangle which is most bottom and left position
      ret = base
    else:
      ret = rectArrayTemp[0]
      for i in 1 .. rectArrayTemp.high:
        ret = comparePeak(ret, rectArrayTemp[i])  
  ret
  
proc isSameSizeRect*(rect1, rect2: RectInt): bool =
  var 
    selfRect: RectInt
    ret: bool = false
  
  if rect1.pos == rect2.pos: selfRect = rect1
  else: selfRect = rotateRect(rect1)
  if selfRect.w == rect2.w and
    selfRect.h == rect2.h:
      ret = true
  ret

proc locateRects*(base: RectInt, rects: seq[RectInt], locatedRects: seq[RectInt], space: SpaceInt): seq[RectInt] =
  # 大きい順BL法で長方形を並べる

  # selfBase: baseのコピー
  var selfBase: RectInt = base
  var target: RectInt
  var selfRects: seq[RectInt] = rects
  var selfLRects: seq[RectInt] = locatedRects

  # 長方形集合を面積の大きい順に並べる
  selfRects = sortRect(selfRects, false)

  # 
  #echo rects
  selfBase.index = 0
  target.index = 0
  var 
    i: int = 0
    gettable: bool
  for r in selfRects:
    #echo "roop: ", j, "   ", r.w, " ", r.h
    target = locateRect(selfBase, r, selfLRects, space)
    #echo "target: ", target
    if isSameSizeRect(target, selfBase) or target.w == 0 or target.h == 0: gettable = false else: gettable = true
    if gettable: 
      target.index = i
      #echo target.index
      inc i
      selfLRects.add(target)
      #selfLRects = sortRectWithIndex(selfLRects)
  #echo selfLRects
  selfLRects  

proc delLocatedRects*(rects, locatedRects: seq[RectInt]): seq[RectInt] =
  # rectsから既配置のlocatedRectsを削除
  var 
    r, rl: RectInt
    index: seq[int]
    flag: bool
    self_rs: seq[RectInt] = rects
    self_ls: seq[RectInt] = locatedRects
  for i in 0..<len(self_ls):
    rl = self_ls[i]
    for j in 0..<len(self_rs):
      r = self_rs[j]
      if isSameSizeRect(rl, r): 
        flag = true
        for num in index:
          if num == j: flag = false
        if flag: 
          index.add(j)
          break
  #echo index
  index = index.sort(false)
  #echo index
  for num in index:
    self_rs.delete(num)
  self_rs

proc printFirstRects*(rects: seq[RectInt], step: int){.discardable.} =
  var selfRects: seq[Rect]
  for r in rects: selfRects.add(toMMrect(r))
  echo "===================================================="
  echo fmt"=============== 配置前の長方形: {step} =================="
  for i, r in selfRects:
      echo "index: ", $i, " w: ", $r.w, " h: ", $r.h, " x: ", $r.p0.x, " y: ", $r.p0.y  
  echo "===================================================="
  echo "===================================================="
  echo " "

proc printLocatedRects*(locatedRects, rects: seq[RectInt], step: int){.discardable.} =
  var selfLRects, selfRects: seq[Rect]
  for r in locatedRects: selfLRects.add(toMMrect(r))
  for r in rects: selfRects.add(toMMrect(r))
  echo "===================================================="
  echo fmt"============= 配置された長方形: {step} =================="
  for i, r in selfLRects:
      echo "index: ", $i, " w: ", $r.w, " h: ", $r.h, " x: ", $r.p0.x, " y: ", $r.p0.y  
  echo "===================================================="
  echo "===================================================="
  echo "                                                    "
  echo "===================================================="
  echo fmt"=========== 配置されなかった長方形: {step} =============="
  if selfRects.len != 0:
      for i, r in selfRects:
          echo "index: ", $i, " w: ", $r.w, " h: ", $r.h, " x: ", $r.p0.x, " y: ", $r.p0.y  
  else:
      echo "          全ての長方形が配置されました"
  echo "===================================================="
  echo "===================================================="
  echo "                                                    "  
