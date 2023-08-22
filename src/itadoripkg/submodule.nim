# main program of "Itadori"

import rect
import strformat
import std/rdstdin
import fileio
import strutils



proc makeBase*(baseSize: seq[int], spaceBase: SpaceBase): Rect =
    # ベース長方形の作成
    # 3x6:   914x1829mm
    # 4x8:  1219x2438mm
    # 5x10: 1524x3048mm
    var base: Rect
    base = makeRect(baseSize[0], baseSize[1])
    base = makeBase(base, spaceBase)
    base

proc input*(mode: int, fileName: string = ""): seq[seq[float]] =
    var arr: seq[seq[float]]
    var w, h: float
    # 並べる長方形入力
    case mode
    of 0:
        # テスト
        arr = @[@[2000.0, 1000.0], @[1500.0, 400.0], @[1000.0, 500.0], @[800.0, 300.0], @[600.0, 20.0], @[600.0, 200.0], @[500.0, 200.0], @[400.0, 300.0], @[200.0, 100.0], @[200.0, 100.0], @[200.0, 100.0]]
    of 1:
        # 手動入力
        
        
        echo "配置する長方形のW,Hを入力してください"
        echo "何も入力せずにエンターを押すと終了します"
        var line1, line2: string
        while true:
            var ok = readLineFromStdin("Wを入力してください: ", line1)
            if line1 == "": break # ctrl-C or ctrl-D will cause a break
            w = line1.parseFloat
            ok = readLineFromStdin("Hを入力してください: ", line2)
            if line2 == "": break # ctrl-C or ctrl-D will cause a break    
            h = line2.parseFloat        
            if line1.len > 0 and line2.len > 0: arr.add(@[w, h])
        echo fmt"入力された長方形軍は、{arr} です"
        

    of 2:
        # エクセルファイル読み込み
        arr = readExcelToArray(fileName)

    of 3:
        # CSVファイル読み込み
        arr = readCsvToArray(fileName)
    else:
        arr = @[@[2000.0, 1000.0]]
    arr

proc getLocatableRects*(base: Rect, rects: seq[Rect]): seq[Rects] =
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



#[
proc main*() {.discardable.} = 
    # 大きい順BL法で長方形を並べるプログラム

    # [変数定義]
    # 幅高さの集合変数arr, ベース長方形変数baseSize, 
    # ベース長方形周辺部スペース変数spaceBase,
    # 長方形間隔space変数
    var inputMode: int = 3
    var dirName: string = r"C:\Users\kanto\@DATA\data" #r"C:\Users\y1960\@DATA\Projects\Nim" #"%USERPROFILE%\@DATA\data"
    let excelName: string = "list.xlsx"
    let csvName: string = "list.csv"
    var openName: string
    let saveDir: string = r"C:\Users\kanto\@DATA\data" #r"C:\Users\y1960\@DATA\Projects\Nim" #"%USERPROFILE%\@DATA\data"
    let saveName: string = r"Located.csv"
    let saveFile: string = saveDir & r"\" & saveName
    let drawDir: string = saveDir & r"\draw" #r"C:\Users\y1960\@DATA\Projects\Nim" #"%USERPROFILE%\@DATA\data"

    # 初期値
    var arr:seq[seq[float]]
    var baseSize: seq[int] = @[2438_000, 1219_000]
    var spaceBase: SpaceBase = SpaceBase(sxl: 20_000, sxr: 20_000, syb: 50_000, syt: 20_000)
    var space: Space = Space(sx: 20_000, sy: 20_000)

    # 外周不使用部を考慮したベース長方形の作成
    var base: Rect = makeBase(baseSize, spaceBase)

    # modeによって開くファイル名を選択
    if  inputMode == 2: openName = dirName & r"\" & excelName
    if  inputMode == 3: openName = dirName & r"\" & csvName
    echo "Open File Name: ", openName

    # 幅高さの集合arrの作成
    arr = input(inputMode, openName)
    
    # mm単位floatをum単位intに変換、新たな倍列arrSeqを作成
    var arrSeq: seq[seq[int]]
    for each in arr:
        arrSeq.add(toMicro(each))

    # 幅高さの集合arrSeq: seq[seq[int]]を長方形集合seq[Rect]に変換
    var rects: seq[Rect] = arrToRects(arrSeq)
    var step: int = 0

    #printFirstRects(rects, step)
    inc step

    # [長方形配置]
    # ベース長方形オブジェクト base: Rect
    # 配置する長方形オブジェクト集合　rects：seq[Rect]
    # 長方形間スペース　space: Space
    var firstWrite: bool = true
    while true:
        var locatedRects: seq[Rect] = @[]
        locatedRects = locateRects(base, rects, locatedRects, space)
        
        if locatedRects.len == 0: break

        # rectsから既配置のlocatedRectsを削除
        rects = delLocatedRects(rects, locatedRects)
        
        saveRects(locatedRects, baseSize, saveFile, firstWrite)
        firstWrite = false
        
        # 配置した長方形図形を作成・セーブ
        makePlot(locatedRects, base, fmt"{drawDir}\image{step}.png")
        inc step

]#
