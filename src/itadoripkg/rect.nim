# submodule of Itadori, for easy use of rectangle objects
import strformat

type Point* = object
  # Pointオブジェクト: x,y: int
  x*, y*: int

type Rect* = object
  # 長方形オブジェクト　4つの頂点の配列pkと幅w,高さh
  name*: string
  p0*: Point
  p1*: Point
  p2*: Point
  p3*: Point
  w*, h*: int
  pos*: bool # positive position: true, rotated position: flase
  index*: int # the order added in array

type Rects* = object
  # 長方形の配列オブジェクト
  rects*: seq[Rect]

type RectWithIndex* = object
  # index付きRect
  rwi*: tuple[index: int, rect: Rect]
  
type Space* = object
  # 並べる長方形同士の間のスペースspase-x, space-yオブジェクト
  sx*, sy*: int

type SpaceBase* = object
  # ベース長方形の周辺スペースオブジェクト
  sxl*, sxr*, syb*, syt*: int

#[
iterator eachP*(r: Rect): Point =
  # peaks配列オブジェクトのイテレータ化
  let length = r.peaks.len
  var i = 0
  while i < length:
    yield p.peaks[i]
    inc i
]#


proc reverse*[T](arr: seq[T]): seq[T] =
  var ans: seq[T]
  for i in countdown(arr.high, arr.low):
    ans.add(arr[i])
  ans

proc sort*[T](arr: seq[T], flag: bool = true): seq[T] =
  # ソート　小さい順flag=true, 大きい順flag=false
  var self_arr: seq[T] = arr
  var a, b, index: int
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

proc sortRect*(rects: var seq[Rect], flag: bool = false): seq[Rect] =
  # rectsをソートする　flag=trueで小さい順　flag=falseで大きい順
  let length = len(rects)
  var j, area1, area2, index: int
  var target: Rect
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

proc sortRectWithIndex*(rects: seq[Rect]): seq[Rect] =
  # rectsをソートする　rect.index の小さい順に整列
  var length = rects.len
  var selfRects: seq[Rect]
  var temp: Rect
  for i in 0..<length:
    temp = rects[i]
    for j in (i + 1)..<length:
      if temp.index > rects[j].index:
        temp = rects[j]
        temp.index = i
    selfRects.add(temp)
  selfRects

proc makeRect*(w, h: int, x = 0, y = 0, name = "no name"): Rect =
  # 長方形四隅の点座標をまとめたpkと幅w、高さhで長方形オブジェクトを作成
  var n: string = name
  let xe: int = x + w
  let ye: int = y + h
  var p0, p1, p2, p3: Point
  var r: Rect
  p0 = Point(x: x, y: y)
  p1 = Point(x: xe, y: y)
  p2 = Point(x: x, y: ye)
  p3 = Point(x: xe, y: ye)
  r = Rect(name: n, p0: p0, p1: p1, p2: p2, p3: p3, w: w, h: h, pos: true)
  r

proc rotateRect*(r: Rect): Rect =
  var selfRect: Rect = r
  var t: int
  var flag: bool
  t = selfRect.p3.x
  selfRect.p3.x = selfRect.p3.y
  selfRect.p3.y= t
  selfRect.p1.x = selfRect.p3.x
  selfRect.p2.y = selfRect.p3.y
  if r.pos: flag = false
  else: flag = true
  selfRect.pos = flag
  selfRect

proc makeRectWithSpace*(rect: Rect, s: Space): Rect =
  # 長方形にスペース分を足した長方形オブジェクトを返す
  var selfRect: Rect = rect
  #selfRect.p0.x = selfRect.p0.x
  #selfRect.p0.y = selfRect.p0.y
  selfRect.p1.x = selfRect.p1.x + s.sx
  #selfRect.p1.y = selfRect.p1.y
  #selfRect.p2.x = selfRect.p2.x
  selfRect.p2.y = selfRect.p2.y + s.sy
  selfRect.p3.x = selfRect.p3.x + s.sx
  selfRect.p3.y = selfRect.p3.y + s.sy
  selfRect.w = selfRect.w + s.sx
  selfRect.h = selfRect.h + s.sy
  selfRect

proc makeRectAddLowSpace*(rect: Rect, s: Space): Rect =
  # 長方形にスペース分を足した長方形オブジェクトを返す
  var selfRect: Rect = rect
  selfRect.p0.x = selfRect.p0.x - s.sx
  selfRect.p0.y = selfRect.p0.y - s.sy
  #selfRect.p1.x = selfRect.p1.x
  selfRect.p1.y = selfRect.p1.y - s.sy
  selfRect.p2.x = selfRect.p2.x - s.sx
  #selfRect.p2.y = selfRect.p2.y
  #selfRect.p3.x = selfRect.p3.x
  #selfRect.p3.y = selfRect.p3.y
  selfRect.w = selfRect.w + s.sx
  selfRect.h = selfRect.h + s.sy
  selfRect

proc remakeRectWithOrigin*(rect: Rect, p: Point): Rect =
  # rectに始点pにしてrectを返す
  var selfRect: Rect = rect
  selfRect.p0 = p
  selfRect.p1 = Point(x: p.x + selfRect.w, y: p.y)
  selfRect.p2 = Point(x: p.x, y: p.y + selfRect.h)
  selfRect.p3 = Point(x: p.x + selfRect.w, y: p.y + selfRect.h)
  selfRect

proc makeBase*(rect: Rect, s: SpaceBase): Rect =
  # ベース長方形の周辺部スペースを削除した配置可能なサイズの長方形オブジェクトを返す
  var selfRect: Rect = rect
  selfRect.p0.x = selfRect.p0.x + s.sxl
  selfRect.p0.y = selfRect.p0.y + s.syb
  selfRect.p1.x = selfRect.p1.x - s.sxr
  selfRect.p1.y = selfRect.p1.y + s.syb
  selfRect.p2.x = selfRect.p2.x + s.sxl
  selfRect.p2.y = selfRect.p2.y - s.syt
  selfRect.p3.x = selfRect.p3.x - s.sxr
  selfRect.p3.y = selfRect.p3.y - s.syt
  selfRect.w = selfRect.w - s.sxl - s.sxr
  selfRect.h = selfRect.h - s.syb - s.syt
  selfRect

proc arrToRects*(arrSeq: seq[seq[int]]): seq[Rect] =
    # rectangles:seq[seq[int]]をrects:seq[Rect]に変換(各長方形の原点はX:0,y:0)
    var w, h: int
    var rect: Rect
    var rects: seq[Rect]
    for each in arrSeq:
        w = each[0]
        h = each[1]
        rect = makeRect(w, h)
        rects.add(rect)
    rects

proc echoRects*(rects: seq[Rect]) =
  var i = 1
  for rect in rects:
    echo fmt"""Rect No.{i}:
    p0(x, y): ({rect.p0.x}, {rect.p0.y}) 
    p1(x, y): ({rect.p1.x}, {rect.p1.y}) 
    p2(x, y): ({rect.p2.x}, {rect.p2.y}) 
    p3(x, y): ({rect.p3.x}, {rect.p3.y}) 
    width: {rect.w} um
    height: {rect.h} um"""
    inc i
  discard

proc isLocatable*(rb, ri: Rect): bool =
  # 長方形rbに長方形riがサイズ上含まれるか判定
  (rb.w >= ri.w and rb.h >= ri.h)

proc isInclude*(rb, ri: Rect): bool =
  # 長方形rbに長方形riが座標上含まれるか判定
  (rb.p0.x <= ri.p0.x and rb.p1.x >= ri.p1.x and
    rb.p0.y <= ri.p0.y and rb.p2.y >= ri.p2.y)

proc isSame*(rb, ri: Rect): bool =
  # 長方形rbと長方形riが重なっているか判定
  var flag: bool = false
  var bmin, bmax, imin, imax: Point
  bmin = rb.p0
  bmax = rb.p3
  imin = ri.p0
  imax = ri.p3
  if bmin == imin and bmax == imax: flag = true
  flag

proc isOverlap*(rb, ri: Rect): bool =
  # 長方形rbと長方形riが重なっているか判定
  var flag: bool = false
  var x1, x2, x3, x4, y1, y2, y3, y4: int
  x1 = rb.p0.x
  x2 = rb.p3.x
  y1 = rb.p0.y
  y2 = rb.p3.y
  x3 = ri.p0.x
  x4 = ri.p3.x
  y3 = ri.p0.y
  y4 = ri.p3.y
  if (max(x1, x3) < min(x2, x4)) and (max(y1, y3) < min(y2, y4)): flag = true
  flag

