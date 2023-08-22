import rect

proc toMicro*(p: seq[float]): seq[int] =
    var x: int = int(p[0] * 1000)
    var y: int = int(p[1] * 1000)
    var a: seq[int] = @[x, y]
    a

proc toMili*(r: Rect): seq[float] =
    var x: float = float(r.p0.x / 1000)
    var y: float = float(r.p0.y / 1000)
    var w: float = float(r.w / 1000)
    var h: float = float(r.h / 1000)
    var ans: seq[float] = @[x, y, w, h]
    ans

proc toMMFloat*[T](i: T): float =
    var ans: float = float(i / 1000)
    ans

proc toUMInt*[T](i: T): int =
    var ans: int = int(i * 1000)
    ans