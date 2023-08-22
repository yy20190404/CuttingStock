import rect

proc toMicro*(p: seq[float]): seq[int] =
    # Convert mm unit float to um unit integer as array p[width, height]
    let
        x: int = int(p[0] * 1000)
        y: int = int(p[1] * 1000)
    var ans: seq[int] = @[x, y]
    ans

proc toMili*(r: Rect): seq[float] =
    # Convert um unit integer to mm unit float from Rect as array ans[width, height]
    let 
        x: float = float(r.p0.x / 1000)
        y: float = float(r.p0.y / 1000)
        w: float = float(r.w / 1000)
        h: float = float(r.h / 1000)
    var ans: seq[float] = @[x, y, w, h]
    ans

proc toMMFloat*[T](i: T): float =
    # Convert um unit to mm unit float
    var ans: float = float(i / 1000)
    ans

proc toUMInt*[T](i: T): int =
    # Convert mm unit to um unit integer
    var ans: int = int(i * 1000)
    ans