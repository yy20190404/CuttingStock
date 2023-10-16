import nigui
import nigui/msgBox
import strutils
import rect
import fileio
import plot
import strformat
import os
import start
import asyncdispatch

proc setBase*(w, h: float): seq[float] =
  # w, hをミクロンオーダー整数の配列にして返す
  var base: seq[float] = @[w, h]
  base

proc progressRate*(firstLen, restLen: int): float =
  # ProgressBar用　初期配列と現配列の長さの比
  var part = float(restLen) / float(firstLen)
  part

proc manualInput*(fileName: string) =
  ## Show manual input dialog
  var 
    index, qty: int
    width, height: float
    name: string
    names: seq[string] = @[""]
    lineText: string
    le: string = "\r\n"
    returnText: string

  block manualInputwindow: # Manual Input Window
    var miwindow = newWindow()
    miwindow.width = 500.scaleToDpi
    miwindow.height = 300.scaleToDpi

    var miContainer = newLayoutContainer(Layout_Vertical)
    miwindow.add(miContainer)

    var inputContainer = newLayoutContainer(Layout_Vertical)
    miContainer.add(inputContainer)

    var inputContainer1 = newLayoutContainer(Layout_Horizontal)
    inputContainer.add(inputContainer1)
    inputContainer1.frame = newFrame("Input Data")

    var inputContainer2 = newLayoutContainer(Layout_Horizontal)
    inputContainer.add(inputContainer2)

    var inputContainer3 = newLayoutContainer(Layout_Vertical)
    inputContainer2.add(inputContainer3)
    inputContainer3.frame = newFrame("Input Name")

    var inputContainer4 = newLayoutContainer(Layout_Horizontal)
    inputContainer3.add(inputContainer4)

    var inputContainer5 = newLayoutContainer(Layout_Vertical)
    inputContainer2.add(inputContainer5)

    var dataContainer = newLayoutContainer(Layout_Vertical)
    miContainer.add(dataContainer)
    dataContainer.frame = newFrame("Input Data Viewer")

    var label_mi010 = newLabel()
    inputContainer1.add(label_mi010)
    label_mi010.text = "No."

    var textBox_mi010 = newTextBox()
    inputContainer1.add(textBox_mi010)
    textBox_mi010.text = "1"

    var label_mi011 = newLabel()
    inputContainer1.add(label_mi011)
    label_mi011.text = "Width"

    var textBox_mi011 = newTextBox()
    inputContainer1.add(textBox_mi011)

    var label_mi012 = newLabel()
    inputContainer1.add(label_mi012)
    label_mi012.text = "Height"

    var textBox_mi012 = newTextBox()
    inputContainer1.add(textBox_mi012)

    var label_mi013 = newLabel()
    inputContainer1.add(label_mi013)
    label_mi013.text = "Qty"

    var textBox_mi013 = newTextBox()
    inputContainer1.add(textBox_mi013)

    var textBox_mi020 = newTextBox()
    inputContainer3.add(textBox_mi020)

    var label_mi021 = newLabel()
    inputContainer5.add(label_mi021)

    var button_mi020 = newButton("Input")
    inputContainer5.add(button_mi020)

    var textArea030 = newTextArea()
    dataContainer.add(textArea030)

    var dataContainer1 = newLayoutContainer(Layout_Horizontal)
    dataContainer.add(dataContainer1)

    var label_mi030 = newLabel()
    dataContainer1.add(label_mi030)
    label_mi030.text = "                                                                                                       "

    var button_mi030 = newButton("OK")
    dataContainer1.add(button_mi030)

    var button_mi031 = newButton("Cancel")
    dataContainer1.add(button_mi031)

    block clickEvents: # button click events
      button_mi020.onClick = proc(event: ClickEvent) =
        index = textBox_mi010.text.parseInt
        width = textBox_mi011.text.parseFloat
        height = textBox_mi012.text.parseFloat
        qty = textBox_mi013.text.parseInt
        name = textBox_mi020.text
        if textArea030.text == "": textArea030.text = "No.,Width,Height,Qty,Name" & le

        lineText = $index & "," & $width & "," &  $height & "," & $qty & "," & name & le
        returnText = textArea030.text
        returnText = returnText & lineText
        textArea030.text = returnText

        names.add(name)

        index = index + 1
        textBox_mi010.text = $index
        textBox_mi011.text = ""
        textBox_mi012.text = ""
        textBox_mi013.text = ""
        textBox_mi020.text = name
        textBox_mi011.focus

      button_mi030.onClick = proc(event: ClickEvent) =
        let tempFile = fileName.splitPath.head & "\\temp.csv"
        writeFile(tempFile, returnText)
        miwindow.hide()

      button_mi031.onClick = proc(event: ClickEvent) =
        returnText = ""
        let tempFile = fileName.splitPath.head & "\\temp.csv"
        writeFile(tempFile, returnText)
        miwindow.hide()
    
    miwindow.show()


proc showWindow*()=
  # #############################################################################
  # Show Window for GUI
  # #############################################################################

  var data: Data = initConfig()  # read ini.json

  var # set variables
    sxl = data.baseSpace.sxl
    sxr = data.baseSpace.sxr
    syb = data.baseSpace.syb
    syt = data.baseSpace.syt
    sx = data.space.sx
    sy = data.space.sy
    openFile, saveFile, drawDir: string
    noNgFlag: bool = false
    imageFiles: seq[string] = @[]

  block files: # set file names
    if data.inputFullName == "":
      openFile = getenv(data.drive) & getenv(data.homePath) & "\\list.csv"
    else:
      openFile = data.inputFullName

    if data.outputFullName == "":
      saveFile = getenv(data.drive) & getenv(data.homePath) & "\\located.csv"
    else:
      saveFile = data.outputFullName
    #if not existsDir(splitPath(saveFile).head): createDir(splitPath(saveFile).head)
    #if not existsFile(saveFile): writefile(saveFile, "")

    drawDir = data.drawDir
    if drawDir == "": data.drawDir = getenv(data.drive) & getenv(data.homePath) & "\\draw"
    #if not os.existsDir(data.drawDir): createDir(data.drawDir) 

  app.init() # Initialization of window app

  # show start window
  var winImage: Window = newWindow()
  waitFor startWindow(winImage, "..\\images\\top3.png")

 # set main window elements
  var window = newWindow()
  window.width = 600.scaleToDpi
  window.height = 500.scaleToDpi

  var mainContainer = newLayoutContainer(Layout_Vertical)
  window.add(mainContainer)

  var input1 = newLayoutContainer(Layout_Horizontal)
  mainContainer.add(input1)

  var output1 = newLayoutContainer(Layout_Horizontal)
  mainContainer.add(output1)

  var output2 = newLayoutContainer(Layout_Horizontal)
  mainContainer.add(output2)

  var valueBase = newLayoutContainer(Layout_Horizontal)
  mainContainer.add(valueBase)

  var value1 = newLayoutContainer(Layout_Vertical)
  valueBase.add(value1)

  var plate1 = newLayoutContainer(Layout_Horizontal)
  value1.add(plate1)

  var plate2 = newLayoutContainer(Layout_Horizontal)
  value1.add(plate2)

  var plate3 = newLayoutContainer(Layout_Horizontal)
  value1.add(plate3)

  var plate4 = newLayoutContainer(Layout_Horizontal)
  value1.add(plate4)

  var value2 = newLayoutContainer(Layout_Vertical)
  valueBase.add(value2)

  var space1 = newLayoutContainer(Layout_Horizontal)
  value2.add(space1)

  var space2 = newLayoutContainer(Layout_Horizontal)
  value2.add(space2)

  var space3 = newLayoutContainer(Layout_Horizontal)
  value2.add(space3)

  var space4 = newLayoutContainer(Layout_Horizontal)
  value2.add(space4)

  var value3 = newLayoutContainer(Layout_Vertical)
  valueBase.add(value3)

  var space5 = newLayoutContainer(Layout_Horizontal)
  value3.add(space5)

  var space6 = newLayoutContainer(Layout_Horizontal)
  value3.add(space6)

  var space7 = newLayoutContainer(Layout_Horizontal)
  value3.add(space7)

  var space8 = newLayoutContainer(Layout_Vertical)
  space7.add(space8)

  var space9 = newLayoutContainer(Layout_Vertical)
  space7.add(space9)

  var monitor1 = newLayoutContainer(Layout_Vertical)
  mainContainer.add(monitor1)

  var monitor2 = newLayoutContainer(Layout_Vertical)
  mainContainer.add(monitor2)

  var control1 = newLayoutContainer(Layout_Horizontal)
  mainContainer.add(control1)

  var progress1 = newLayoutContainer(Layout_Vertical)
  control1.add(progress1)

  var progress2 = newLayoutContainer(Layout_Vertical)
  control1.add(progress2)

  var buttons2 = newLayoutContainer(Layout_Horizontal)
  control1.add(buttons2)

  var label010 = newLabel()
  input1.add(label010)
  label010.text = "Load File         "

  var textBox010 = newTextBox()
  input1.add(textBox010)
  textBox010.text = openFile

  var button010 = newButton("Open")
  input1.add(button010)

  var label020 = newLabel()
  output1.add(label020)
  label020.text = "Save File        "
  
  var textBox020 = newTextBox()
  output1.add(textBox020)
  textBox020.text = saveFile

  var button020 = newButton("Open")
  output1.add(button020)  

  var label030 = newLabel()
  output2.add(label030)
  label030.text = "Images Folder"

  var textBox030 = newTextBox()
  output2.add(textBox030)
  textBox030.text = data.drawDir

  var button030 = newButton("Open")
  output2.add(button030)  

  # set button onClick section
  button010.onClick = proc(event: ClickEvent) =
      # Open file dialog
      var dialog = newOpenFileDialog()
      dialog.title = "Select Open File"
      dialog.multiple = false
      dialog.directory = data.drive & data.homePath
      dialog.run()
      if dialog.files.len == 0: 
        textBox010.text = ""
      else:
        textBox010.text = dialog.files[0]
      
  # set botton onClick
  button020.onClick = proc(event: ClickEvent) =
    # Save file dialog
    var dialog = newOpenFileDialog()
    dialog.title = "Select Save File"
    dialog.multiple = false
    dialog.directory = data.drive & data.homePath

    dialog.run()
    if dialog.files.len == 0: 
      textBox020.text = ""
    else:
      textBox020.text = dialog.files[0]

  button030.onClick = proc(event: ClickEvent) =
    # Save images directory dialog
    var dialog = SelectDirectoryDialog()
    dialog.title = "Select Directory for images"
    dialog.startDirectory = data.drive & data.homePath
    dialog.run()
    if dialog.selectedDirectory == "":
      textBox030.text = ""
    else:
      textBox030.text = dialog.selectedDirectory
  
  # set checkbox section
  var checkBox010 = newCheckbox("")
  plate1.add(checkBox010)
  if data.baseSize.name == "5x10": checkBox010.checked = true
  else: checkBox010.checked = false

  var label040 = newLabel()
  plate1.add(label040)
  label040.text = "5x10: "

  var label041 = newLabel()
  plate1.add(label041)
  label041.text = "3048mm x 1524mm"

  var checkBox020 = newCheckbox("")
  plate2.add(checkBox020)
  if data.baseSize.name == "4x8": checkBox020.checked = true
  else: checkBox020.checked = false
  
  var label050 = newLabel()
  plate2.add(label050)
  label050.text = "4x8:  "
  
  var label051 = newLabel()
  plate2.add(label051)
  label051.text = "2438mm x 1219mm"

  var checkBox030 = newCheckbox("")
  plate3.add(checkBox030)
  if data.baseSize.name == "3x6": checkBox030.checked = true
  else: checkBox030.checked = false

  var label060 = newLabel()
  plate3.add(label060)
  label060.text = "3x6:  "
  
  var label061 = newLabel()
  plate3.add(label061)
  label061.text = "1829mm x 914mm "

  var checkBox040 = newCheckbox("")
  plate4.add(checkBox040)
  if data.baseSize.name == "free": checkBox040.checked = true
  else: checkBox040.checked = false

  var label070 = newLabel()
  plate4.add(label070)
  label070.text = "free: "
  
  var textBox070 = newTextBox()
  plate4.add(textBox070)

  var label071 = newLabel()
  plate4.add(label071)
  label071.text = " x "

  var textBox071 = newTextBox()
  plate4.add(textBox071)

  # set checkbox onClick section
  checkBox010.onClick = proc(event: ClickEvent) =
    checkBox020.checked = false
    checkBox030.checked = false
    checkBox040.checked = false
    textBox070.text = ""
    textBox070.editable = false
    textBox071.text = ""
    textBox071.editable = false

  checkBox020.onClick = proc(event: ClickEvent) =
    checkBox010.checked = false
    checkBox030.checked = false
    checkBox040.checked = false
    textBox070.text = ""
    textBox070.editable = false
    textBox071.text = ""
    textBox071.editable = false

  checkBox030.onClick = proc(event: ClickEvent) =
    checkBox010.checked = false
    checkBox020.checked = false
    checkBox040.checked = false
    textBox070.text = ""
    textBox070.editable = false
    textBox071.text = ""
    textBox071.editable = false
    
  checkBox040.onClick = proc(event: ClickEvent) =
    checkBox010.checked = false
    checkBox020.checked = false
    checkBox030.checked = false
    textBox070.editable = true
    textBox071.editable = true
    textBox070.text = "2000.0"
    textBox071.text = "1000.0"

  # set Spaces of base rectanble desided section
  var label080 = newLabel()
  space1.add(label080)
  label080.text = "Base Left Space      "

  var textBox080 = newTextBox()
  space1.add(textBox080)
  textBox080.text = $sxl

  var label090 = newLabel()
  space2.add(label090)
  label090.text = "Base Right Space   "

  var textBox090 = newTextBox()
  space2.add(textBox090)  
  textBox090.text = $sxr

  var label100 = newLabel()
  space3.add(label100)
  label100.text = "Base Bottom Space"

  var textBox100 = newTextBox()
  space3.add(textBox100)
  textBox100.text = $syb

  var label110 = newLabel()
  space4.add(label110)
  label110.text = "Base Top Space     "

  var textBox110 = newTextBox()
  space4.add(textBox110)  
  textBox110.text = $syt


  # ##########################
  # Spaces betwenn rectangles desided section
  # ##########################
  var label120 = newLabel()
  space5.add(label120)
  label120.text = "Between x"

  var textBox120 = newTextBox()
  space5.add(textBox120)  
  textBox120.text = $sx

  var label121 = newLabel()
  space6.add(label121)
  label121.text = "Between y"
  
  var textBox121 = newTextBox()
  space6.add(textBox121)  
  textBox121.text = $sy

  var label122 = newLabel()
  space8.add(label122)
  label122.text = "          "

  var label123 = newLabel()
  space8.add(label123)

  var progressBar1 = newProgressBar()
  progressBar1.value = 0
  space8.add(progressBar1)

  var button041 = newButton("Manual Input")
  space9.add(button041)

  var button040 = newButton("Get Data")
  space9.add(button040)




  # set Progress bar section
  var label160 = newLabel()
  progress1.add(label160)
  label160.text = "        "

  var label161 = newLabel()
  progress1.add(label161)
  label161.text = "Progress"

  # set input and output data on textArea section
  # ##########################
  # Show input rectangles section
  # ##########################
  var label140 = newLabel()
  monitor1.add(label140)
  label140.text = "Locating rectangles"

  var textArea140 = newTextArea()
  monitor1.add(textArea140)


  # ##########################
  # Show located rectangles section
  # ##########################
  var label150 = newlabel()
  monitor2.add(label150)
  label150.text = "Located rectangles"

  var textArea150 = newTextArea()
  monitor2.add(textArea150)


  # set Buttons secti
  var label170 = newLabel()
  progress2.add(label170)
  label170.text = "                                                                                                    "

  var progressBar2 = newProgressBar()
  progressBar2.value = 0
  progress2.add(progressBar2)

  var button050 = newbutton("Quit")
  buttons2.add(button050)

  var button051 = newbutton("Start Locating")
  buttons2.add(button051)

  # ##########################
  # Button onClick events: Manual Input
  # ##########################
  button041.onClick = proc(event: ClickEvent) =
    var fileName: string
    if textBox010.text != "": openFile = textbox010.text
    textBox010.text = ""
    fileName = openFile
    manualInput(fileName)

    # Button onClick event: Get data
  button040.onClick = proc(event: ClickEvent) =
    # get file names from textBoxes
    if textBox010.text != "": openFile = textbox010.text 
    saveFile = textBox020.text
    data.drawDir = textBox030.text

    # get Input Data
    # ------------------------------
    # Get Data 
    # ------------------------------
    block doProcess:
      if not existsFile(openFile) or saveFile == "" or not existsFile(saveFile) or data.drawDir == "" or not existsDir(data.drawDir):
        case window.msgBox("Open File, Save File, Images Folderは有効なものを指定して下さい　　\n終了します", "WARINIG", "Quit")
        of 1: app.quit()
        of 2: window.minimize()
        of 3: discard
        else: app.quit()
        break doProcess

    var w, h: float
    var inputMode: int

    # ベースサイズの取得
    if checkBox010.checked:
      data.baseSize.name = "5x10"
      w = 3048.0
      h = 1524.0
    if checkBox020.checked:
      data.baseSize.name = "4x8"
      w = 2438.0
      h = 1219.0
    if checkBox030.checked:
      data.baseSize.name = "3x6"
      w = 1829.0
      h = 914.0
    if checkBox040.checked:
      data.baseSize.name = "free"
      w = textBox070.text.parseFloat
      h = textBox071.text.parseFloat

    # TextBox1の入力内容から取得データのモード決定
    var extension: string
    if textBox010.text == "test": inputMode = 0
    elif textBox010.text == "": inputMode = 1
    else:
      extension = openfile[^3 .. ^1]
      if extension == "xls" or extension == "lsx": inputMode = 2
      elif extension == "csv": inputMode = 3
      else: inputMode = 99

    # ベースサイズ・スペースの取得
    var arr:seq[Rect]
    var baseSize: seq[float] = @[w, h]

    # 幅高さの集合arrの作成
    arr = setInputMode(inputMode, openFile)

    # 配置する長方形の情報をテキストアレアに表示
    var text: string = fmt"Base Size: {baseSize[0]} x {baseSize[1]} mm" & "\r\n"
    text = text & "=== Rectangles to be located ===\r\n"
    text = text & "No., Width, Height, name\r\n"
    var i = 1
    var all = arr.len
    for s in arr:
      progressBar1.value = float(i/all)
      text = text & fmt"{i}, {s.w}, {s.h}, {s.name}" & "\r\n"
      inc i
    textArea140.text = text  

  # quit on button50 onClicked 
  button050.onClick = proc(event: ClickEvent) =
    app.quit()

  # Button onClick event: located rectangles
  # ------------------------------
  # Get Located 
  # ------------------------------
  button051.onClick = proc(event: ClickEvent) =
  
    winImage.dispose()
    # File名の取得
    if textBox010.text != "": openFile = textbox010.text 
    saveFile = textBox020.text
    data.drawDir = textBox030.text

    block doProcess:
      if not existsFile(openFile) or saveFile == "" or not existsFile(saveFile) or data.drawDir == "" or not existsDir(data.drawDir):
        case window.msgBox("Open File, Save File, Images Folderは有効なものを指定して下さい　　\n終了します", "WARINIG", "Quit")
        of 1: app.quit()
        of 2: window.minimize()
        of 3: discard
        else: app.quit()
        break doProcess
      
    # ベースサイズ・スペースの取得
    sxl = textBox080.text.parseFloat 
    sxr = textBox090.text.parseFloat
    syb = textBox100.text.parseFloat
    syt = textBox110.text.parseFloat
    sx = textBox120.text.parseFloat
    sy = textBox121.text.parseFloat

    var w, h: float
    var inputMode: int

    # ベースサイズの取得
    if checkBox010.checked:
      data.baseSize.name = "5x10"
      w = 3048.0
      h = 1524.0
    if checkBox020.checked:
      data.baseSize.name = "4x8"
      w = 2438.0
      h = 1219.0
    if checkBox030.checked:
      data.baseSize.name = "3x6"
      w = 1829.0
      h = 914.0
    if checkBox040.checked:
      data.baseSize.name = "free"
      w = textBox070.text.parseFloat
      h = textBox071.text.parseFloat

    # TextBox1の入力内容から取得データのモード決定
    var extension: string
    if textBox010.text == "test": inputMode = 0
    elif textBox010.text == "": inputMode = 1
    else:
      extension = openfile[^3 .. ^1]
      if extension == "xls" or extension == "lsx": inputMode = 2
      elif extension == "csv": inputMode = 3
      else: inputMode = 99

    # ベースサイズ・スペースの取得
    var arr:seq[Rect]
    var baseSize: seq[float] = @[w, h]

    # 幅高さの集合arrの作成
    arr = setInputMode(inputMode, openFile)

    # 配置する長方形の情報をテキストエリアに表示
    var text: string = fmt"Base Size: {baseSize[0]} x {baseSize[1]} mm" & "\r\n"
    text = text & "=== Rectangles to be located ===\r\n"
    text = text & "No., Width, Height, name\r\n"
    var i = 1
    var all = arr.len
    for s in arr:
      progressBar1.value = float(i/all)
      progressBar2.value = float(i/(all * 4))
      text = text & fmt"{i}, {s.w}, {s.h}, {s.name}" & "\r\n"
      inc i
    textArea140.text = text  

    # ################################
    # From here: Locating calculation
    var baseFloat: Rect = getRect(baseSize[0], baseSize[1])
    var baseInt: RectInt = toRectUM(baseFloat)
    var spaceBaseInt: SpaceBaseInt = 
      SpaceBaseInt(
        sxl: toUM(textBox080.text.parseFloat), 
        sxr: toUM(textBox090.text.parseFloat), 
        syb: toUM(textBox100.text.parseFloat), 
        syt: toUM(textBox110.text.parseFloat)
      )
    var spaceInt: SpaceInt = 
      SpaceInt(
        sx: toUM(textBox120.text.parseFloat), 
        sy: toUM(textBox121.text.parseFloat)
      )



    # 外周不使用部を考慮したベース長方形の作成
    var rectsInt: seq[RectInt]
    var ngInt: seq[RectInt]
    var arrayRectsInt: seq[seq[RectInt]]
    var ngText: string #= "### Base ###\n"
    var step: int
    var firstWrite: bool = true
    var locatedRectsFloat: seq[Rect]
    var locatedRects: seq[RectInt] = @[]
    var text2: string = ""
    var img: string
    var stepText: string
    var pl: int

    baseInt = getBaseInt(baseInt, spaceBaseInt)
        
    progressBar2.value = 0.3
    arrayRectsInt = getAllRects(baseInt, arr, spaceInt, spaceBaseInt) #getAllRects*(base: seq[float], rects: seq[Rect], space: SpaceInt, spaceBaseInt: SpaceBaseInt): seq[seq[RectInt]]
    progressBar2.value = 0.4

    pl = arrayRectsInt.len
    step = 1
    for i, rects in arrayRectsInt:
      if i == 0: 
        rectsInt = arrayRectsInt[0]
      elif i == 1:
        progressBar2.value = 0.5
        ngInt = arrayRectsInt[1]
        if ngInt.len == 0: noNgFlag = true
        ngText = ngText & "index: , width: , heihgt, Qty, Name: \n"
        for i, r in ngInt:
          ngText = ngText & $i & "," & $toRectMM(r).w & "," & $toRectMM(r).h & "," & $1 & ","  & r.name & "\n"
        var savePath = savefile.splitpath.head & r"\unlocated.csv"
        writeFile(savePath, ngText)
      else:
        progressBar2.value = 0.5 + ((i + 1)/pl*0.5)
        locatedRects = arrayRectsInt[i]

        # 配置済データをテキストエリアに表示
        text2 = text2 & fmt"=== {step}枚目 ===" & "\r\n"
        text2 = text2 & "No., Origin X, Origin Y, Width, Height, Name" & "\r\n"
        for i, r in locatedRects:
          text2 = text2 & fmt"{i}, {toRectMM(r).p0.x}, {toRectMM(r).p0.y}, {toRectMM(r).w}, {toRectMM(r).h}, {r.name}" & "\r\n"
        textArea150.text = text2
        

        # 配置済データをcsvファイルに書き込み
        locatedRectsFloat = @[]
        for r in locatedRects: locatedRectsFloat.add(toRectMM(r))
        saveRects(locatedRectsFloat, baseSize, saveFile, firstWrite)
        firstWrite = false

        # 配置した長方形図形を作成・セーブ
        if not os.existsDir(data.drawDir): createDir(data.drawDir) 
        baseFloat = toRectMM(baseInt)
        if step < 10: stepText = "000" & $step
        elif step < 100: stepText = "00" & $step
        elif step < 1000: stepText = "0" & $step
        else: stepText = $step
        img = data.drawDir & "\\image" & stepText & ".png"
        imageFiles.add(img)
        makePlot(locatedRectsFloat, baseFloat, fmt"{data.drawDir}\image{stepText}.png")
        
        inc step

    #ウィンドウの各値をDataに書き込み
    data.inputFullName = openFile 
    data.outputFullName = saveFile 
    data.baseSize.name = data.baseSize.name
    data.baseSize.width = w 
    data.baseSize.height = h 
    data.baseSpace.sxl = sxl 
    data.baseSpace.sxr = sxr 
    data.baseSpace.syb = syb 
    data.baseSpace.syt = syt 
    data.space.sx = sx 
    data.space.sy = sy 

    #DataをJsonファイルとして保存
    var jsonFile: string = getJsonPath()
    fileio.saveJson(jsonFile, data)

    var msg: string
    # Close Dialogの表示
    if noNgFlag:
      #label301.text = "板取は正常に終了しました        "
      msg = "板取は正常に終了しました        "
    else:
      #label301.text = "板取は正常に終了しました\r\n配置できなかった長方形は\r\nunlocated.csvに保存しました    "
      msg = "板取は正常に終了しました\r\n配置できなかった長方形は\r\nunlocated.csvに保存しました    "
    
    progressBar1.value = 0
    progressBar2.value = 0  

    #closew.show()
    case window.msgBox(msg, "終了", "OK")
    of 1: discard
    else: discard
    startImageWindow(imageFiles)

  # show quit daialog when quit icon clicked
  window.onCloseClick = proc(event: CloseClickEvent) =
    case window.msgBox("Do you want to quit?", "Quit?", "Quit", "Minimize", "Cancel")
    of 1: app.quit()
    of 2: window.minimize()
    else: discard

  window.show()
    
  app.run()