import rect
import strformat

proc makeBase*(baseSize: seq[int], spaceBase: SpaceBase): Rect =
    # ベース長方形の作成
    # 3x6:   914x1829mm
    # 4x8:  1219x2438mm
    # 5x10: 1524x3048mm
    var base: Rect
    base = makeRect(baseSize[0], baseSize[1])
    base = makeBase(base, spaceBase)
    base                                                                                 

proc getLocatableRects*(base: Rect, rects: seq[Rect]): seq[Rects] =
    # Return locatable rectangles only
    var okey: Rects
    var ng: Rects
    okey.rects = @[]
    ng.rects = @[]
    var ansSeq: seq[Rects]
    for r in rects:
        if isLocatable(base, r):
            okey.rects.add(r)
        elif isLocatable(base, rotateRect(r)):
            okey.rects.add(rotateRect(r))
        else:
            ng.rects.add(r)
    ansSeq = @[okey, ng]
    ansSeq

proc locateRect*(base: Rect, target: Rect, locatedRects: seq[Rect], space: Space): Rect =
    # Locate rectangles as BL method
    var tempRects: seq[Rect] = @[]
    var selfTarget, rotatedTarget: Rect
    var flagOverlap: bool
    rotatedTarget = rotateRect(target)
    if locatedRects.len == 0: 
        #echo "No.0"
        if rect.isLocatable(base, target):
            selfTarget = remakeRectWithOrigin(target, base.p0)
        else:
            selfTarget = rect.rotateRect(target)
            if rect.isLocatable(base, selfTarget):
                selfTarget = remakeRectWithOrigin(selfTarget, base.p0)
            else:
                echo "Error: targetRect is too big for base"
        return selfTarget
    for r in locatedRects: tempRects.add(makeRectWithSpace(r, space))
    for r in tempRects:
        selfTarget = remakeRectWithOrigin(target, r.p1)
        if isInclude(base, selfTarget):
            flagOverlap = false
            for rj in tempRects:
                if isOverlap(makeRectAddLowSpace(rj, space), selfTarget): 
                    flagOverlap = true
                    break
            if not flagOverlap: 
                #echo "No.1"
                return selfTarget   
        
        selfTarget = remakeRectWithOrigin(rotatedTarget, r.p1)
        if isInclude(base, selfTarget):
            flagOverlap = false
            for rj in tempRects:
                if isOverlap(makeRectAddLowSpace(rj, space), selfTarget): 
                    flagOverlap = true
                    break
            if not flagOverlap: 
                #echo "No.2"
                return selfTarget
        
        selfTarget = remakeRectWithOrigin(target, r.p2)
        #echo "target: ", selfTarget
        if isInclude(base, selfTarget):
            flagOverlap = false
            for rj in tempRects:
                if isOverlap(makeRectAddLowSpace(rj, space), selfTarget): 
                    flagOverlap = true
                    #echo "Overlaped rect: ", rj
                    break
            if not flagOverlap: 
                #echo "no.3"
                return selfTarget   
        
        selfTarget = remakeRectWithOrigin(rotatedTarget, r.p2)
        if isInclude(base, selfTarget):
            flagOverlap = false
            for rj in tempRects:
                if isOverlap(makeRectAddLowSpace(rj, space), selfTarget): 
                    flagOverlap = true
                    break
            if not flagOverlap: 
                #echo "No.4"
                return selfTarget    
     
    return base

proc locateRects*(base: Rect, rects: seq[Rect], locatedRects: seq[Rect], space: Space): seq[Rect] =
    # 大きい順BL法で長方形を並べる

    # selfBase: baseのコピー
    var selfBase: Rect = base
    var target: Rect
    var selfRects: seq[Rect] = rects
    var selfLRects: seq[Rect] = locatedRects

    # 長方形集合を面積の大きい順に並べる
    selfRects = sortRect(selfRects, false)

    # 
    #echo rects
    selfBase.index = 0
    target.index = 0
    var i: int = 0
    for r in selfRects:
        target = locateRect(selfBase, r, selfLRects, space)
        if target != selfBase: 
            target.index = i
            #echo target.index
            inc i
            selfLRects.add(target)
            #selfLRects = sortRectWithIndex(selfLRects)
    selfLRects
    

proc delLocatedRects*(rects, locatedRects: seq[Rect]): seq[Rect] =
    # rectsから既配置のlocatedRectsを削除
    var r, rl: Rect
    var index: seq[int]
    var flag: bool
    var self_rs: seq[Rect] = rects
    var self_ls: seq[Rect] = locatedRects
    for i in 0..<len(self_ls):
        rl = self_ls[i]
        for j in 0..<len(self_rs):
            r = self_rs[j]
            if (rl.pos and rl.w == r.w and rl.h == r.h) or (not rl.pos and rl.w == r.h and rl.h == r.w): 
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

proc printFirstRects*(rects: seq[Rect], step: int){.discardable.} =
    echo "===================================================="
    echo fmt"=============== 配置前の長方形: {step} =================="
    for i, r in rects:
        echo "index: ", i, " w: ", r.w, " h: ", r.h, " x: ", r.p0.x, " y: ", r.p0.y  
    echo "===================================================="
    echo "===================================================="
    echo " "

proc printLocatedRects*(locatedRects, rects: seq[Rect], step: int){.discardable.} =
    echo "===================================================="
    echo fmt"============= 配置された長方形: {step} =================="
    for i, r in locatedRects:
        echo "index: ", i, " w: ", r.w, " h: ", r.h, " x: ", r.p0.x, " y: ", r.p0.y  
    echo "===================================================="
    echo "===================================================="
    echo "                                                    "
    echo "===================================================="
    echo fmt"=========== 配置されなかった長方形: {step} =============="
    if rects.len != 0:
        for i, r in rects:
            echo "index: ", i, " w: ", r.w, " h: ", r.h, " x: ", r.p0.x, " y: ", r.p0.y  
    else:
        echo "          全ての長方形が配置されました"
    echo "===================================================="
    echo "===================================================="
    echo "                                                    "  
