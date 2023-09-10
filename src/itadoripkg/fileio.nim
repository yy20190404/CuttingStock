import strformat
import rect

import std/parsecsv
import strutils
import excelin
import os
import std/json

type
  # Type declaration regaring json file
  Extension* = object
    excelOld*, excel*, csv*: string

  BaseSize* = object
    name*: string
    width*: float
    height*: float

  BaseSpaceF* = object
    sxl*, sxr*, syb*, syt* : float

  SpaceF* = object
    sx*, sy*: float

  Data* = object
    drive*, homePath*, inputName*, outputName*, inputFullName*, outputFullName*, drawDir*: string
    extension*: Extension
    baseSize*: BaseSize
    baseSpace*: BaseSpaceF
    space*:  SpaceF

proc readJson*(fileName: string): Data =
  # Read json file then set data into Data type
  var path = fileName 
  var f: File
  var data: Data
  var jsonNode: JsonNode
  if fileExists(path): 
    f = open(path)
    jsonNode = parseJson(f.readall())
    f.close()
    data = to(jsonNode, Data)
  data

proc getJsonPath*(): string =
  # Get json path from current path
  let currentPath: string = paramStr(0)
  var path: string = splitPath(currentPath).head
  var jsonFile: string = path & r"\ini.json"
  jsonFile

proc iniConfig*(): Data =
  # Return json Data
  var jsonFile: string = getJsonPath()
  var data: Data = readJson(jsonFile)
  data

proc saveJson*(fileName: string, data: Data) =
  # Save josn file
  let text00 = "{"
  let text01 = fmt""""drive": "{data.drive}", "homePath": "{data.homePath}", "inputName": "{data.inputName}", "inputFullName": "{data.inputFullName}", "outputName": "{data.outputName}", "outputFullName": "{data.outputFullName}", "drawDir": "{data.drawDir}", "extension": """
  let text02 = "{"
  let text03 = fmt""""excelOld": "{data.extension.excelOld}", "excel": "{data.extension.excel}", "csv": "{data.extension.csv}" """
  let text04 = """}, "baseSize": {"""
  let text05 = fmt""""name": "{data.baseSize.name}", "width": {data.baseSize.width}, "height": {data.baseSize.height}"""    
  let text06 = """}, "baseSpace": {"""    
  let text07 = fmt""""sxl": {data.baseSpace.sxl}, "sxr": {data.baseSpace.sxr}, "syb": {data.baseSpace.syb}, "syt": {data.baseSpace.syt}"""    
  let text08 = """}, "space": {""" 
  let text09 = fmt""""sx": {data.space.sx}, "sy": {data.space.sy}""" 
  let text10 = "}}"
  var text = text00 & text01 & text02 & text03 & text04 & text05 & text06 & text07 & text08 & text09 & text10
  var jsonNode: JsonNode = text.parseJson
  writeFile(fileName, jsonNode.pretty())
  

proc saveRects*(rects: seq[Rect], baseSize: seq[float], fileName: string, flag: bool = true){.discardable.}=
  # Save csv file as located rectangle data
  var i: int
  var text: string
  var baseArea, rectArea, rectTotalArea: float
  if flag:
    text = ""
  else:
    text = readFile(fileName)
  text = text & fmt"Base Size:, Width, {baseSize[0]}, Height, {baseSize[1]}" & "\n"
  baseArea = float(baseSize[0] * baseSize[1])
  text = text & fmt"No., LocatedX(mm), LocatedY(mm), Width(mm), Height(mm), name" & "\n"
  i = 1
  rectTotalArea = 0.0
  for r in rects:
    text = text & fmt"{i}, {r.p0.x}, {r.p0.y}, {r.w}, {r.h}, {r.name}" & "\n"
    rectArea = r.w * r.h
    rectTotalArea = rectTotalArea + rectArea
    inc i
  text = text & fmt"Yield:, {rectTotalArea / baseArea * 100}, %" & "\n"
  text = text & "\n"
  writeFile(fileName, text)

proc readCsvToArray*(fileName: string): seq[Rect] =
  # Make array from reading csv file
  var 
    p: CsvParser
    arr: seq[Rect]
    name: string
    w, h: float
    id, qty: int

  p.open(fileName)
  p.readHeaderRow()
  while p.readRow():
    for col in items(p.headers):
      if col == p.headers[0]: id = p.rowEntry(col).parseInt
      if col == p.headers[1]: w = p.rowEntry(col).parseFloat
      if col == p.headers[2]: h = p.rowEntry(col).parseFloat
      if col == p.headers[3]: qty = p.rowEntry(col).parseInt
      if p.headers.len > 4:
        if col == p.headers[4]: name = p.rowEntry(col)
    for i in 1..qty:
      arr.add(makeRect(index = id, w = w, h = h, name = name))
  p.close()
  arr

proc readExcelToArray*(filename: string): seq[Rect] =
  # Make array from readind excel file
  let 
    excel = readExcel(filename)
    sheets = excel.sheetNames
    sheet = excel.getSheet(sheets[0])
  var 
    arr: seq[Rect]
    header: seq[string]
    no, qty: int
    w, h: float
    row: Row
    name: string

  row = sheet.row 1
  for col in 0 ..< 5:
    header.add(row[col.toCol, string])

  var first: bool = true
  for row in sheet.rows:
    if first:
      first = false
    else:
      no =  row["A", int]
      w =   row["B", float]
      h =   row["C", float]
      qty = row["D", int]
      name = row["E", string]
      for j in 0 ..< qty:
        arr.add(makeRect(index = no, w = w, h = h, name = name))
  arr

proc getUserEnv*(userPath: string = "HOMEPATH"): string =
  # Get environment path
  var path: string = ""
  if existsEnv(userPath):
    path = getEnv(userPath)
  path

