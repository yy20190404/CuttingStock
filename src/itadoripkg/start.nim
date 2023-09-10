import nigui
import os
import asyncdispatch
import strutils


proc showImage*(win: Window, img: string) {.async.} = 
  let winStart = win
  winStart.width = 582.scaleToDpi
  winStart.height = 436.scaleToDpi
 
  let ctl = newControl()
  winStart.add(ctl)
  ctl.widthMode = WidthMode_Fill
  ctl.heightMode = HeightMode_Fill
  
  ctl.onClick = proc(c: ClickEvent) =
    echo "Canvas"
  
  let image = newImage()
  image.loadFromFile(img)

  ctl.onDraw = proc(e: DrawEvent) =
    let cv = e.control.canvas

    cv.areaColor = rgb(255,255,255)
    cv.fill

    cv.drawImage(image, 30,20)
  
  #winStart.show()
  

proc startWindow*(w: Window, file: string) {.async.} =
  waitFor showImage(w, file)
  w.show()
  discard sleepAsync(1000)


type
  ImageViewer = ref object
    window: Window
    ctl: Control
    width, height: int
    imagePath: string
    image: Image
    imageL: Image
    imageR: Image

proc makeImageViewer(fileName:string, width, height: int): ImageViewer =
  var win: Window = newWindow(fileName)
  win.width = width.scaleToDpi
  win.height = height.scaleToDpi
  win.title = fileName

  let ctl = newControl()
  win.add(ctl)
  ctl.widthMode = WidthMode_Fill
  ctl.heightMode = HeightMode_Fill

  let imageL = newImage()
  let image = newImage()
  let imageR = newImage()
  imageL.loadFromFile("..\\images\\buttonLeft.png")
  imageR.loadFromFile("..\\images\\buttonRight.png")
  image.loadFromFile(fileName)

  var res = new ImageViewer
  res.window = win
  res.ctl = ctl
  res.width  = width
  res.height = height
  res.imagePath = fileName
  res.image = image
  res.imageL = imageL
  res.imageR = imageR
  return res

proc showImage(iv: ImageViewer, images: seq[string]) =  
  var iv: ImageViewer = iv
  var width = 574
  var height = 436
  var dir, name, ext: string
  var present, len, index: int
  var imageL = newImage()
  var imageR = newImage()
  var image = newImage()
  iv.ctl.onDraw = proc(event: DrawEvent) =
    let cv = event.control.canvas
    cv.areaColor=rgb(255, 255, 255)
    cv.fill
    cv.drawImage(iv.imageL,20,0)
    cv.drawImage(iv.image,50,0)
    cv.drawImage(iv.imageR,630,0)
    cv.drawText(iv.imagePath,30,0)
  iv.ctl.onMouseButtonDown = proc(event: MouseEvent) =
    width = iv.width
    present = event.x
    len = images.len
    dir = splitFile(iv.window.title).dir
    name = splitFile(iv.window.title).name
    ext = splitFile(iv.window.title).ext
    name = name[5 .. 8]
    index = name.parseInt
    if (width/present) > 2:
      if index == 1:
        index = len - 1
      else:
        index = index - 2
    else:
      if index == len:
        index = 0
    imageL.loadFromFile("..\\images\\buttonLeft.png")
    imageR.loadFromFile("..\\images\\buttonRight.png")
    image.loadFromFile(images[index])
    iv = makeImageViewer(images[index], width, height)
    showImage(iv, images)
  iv.window.show()

proc createImageViewer(images: seq[string]) =
  var width = 574
  var height = 436
  var iv: ImageViewer
  var imageL = newImage()
  var imageR = newImage()
  var image = newImage()

  imageL.loadFromFile("..\\images\\buttonLeft.png")
  imageR.loadFromFile("..\\images\\buttonRight.png")
  image.loadFromFile(images[0])
  iv = makeImageViewer(images[0], width, height)
  showImage(iv, images)




proc startImageWindow*(fileNames: seq[string]) =
  createImageViewer(fileNames)

