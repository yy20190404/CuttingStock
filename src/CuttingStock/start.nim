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

proc setImageViewer(fileName:string, width, height: int, image, imageL, imageR: Image): ImageViewer =
  var win: Window = newWindow(fileName)
  win.width = width.scaleToDpi
  win.height = height.scaleToDpi
  win.title = fileName

  let ctl = newControl()
  win.add(ctl)
  ctl.widthMode = WidthMode_Fill
  ctl.heightMode = HeightMode_Fill

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

proc showImages(iv: ImageViewer, images: seq[string]) =  
  var 
    iv: ImageViewer = iv
    width, height: int
    dir, name, ext: string
    present, endIndex, index: int
    imageL: Image = iv.imageL
    imageR: Image = iv.imageR
    image: Image = newImage()

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
    height = iv.height
    #echo width
    present = event.x
    endIndex = images.high
    #echo endIndex

    dir = splitFile(iv.window.title).dir
    name = splitFile(iv.window.title).name
    ext = splitFile(iv.window.title).ext
    #echo name
    name = name[5 .. 8]
    index = name.parseInt - 1
    #echo index
    if (width/present) > 2:
      if index == 0:
        index = endIndex
      else:
        dec index
    else:
      if index == endIndex:
        index = 0
      else:
        inc index
    #echo index
    #echo images[index]
    image.loadFromFile(images[index])
    #echo repr image
    iv.window.dispose()
    iv = setImageViewer(images[index], width, height, image, imageL, imageR)
    showImages(iv, images)
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
  iv = setImageViewer(images[0], width, height, image, imageL, imageR)
  showImages(iv, images)
  #for i, img in images:
  #  echo i, " ", img

proc startImageWindow*(fileNames: seq[string]) =
  createImageViewer(fileNames)

