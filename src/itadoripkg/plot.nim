import nimpy # pltからの.呼出でnimpyが要る
import rect

proc makeDraw*(){.discardable.}=
  let plt = pyImport("matplotlib.pyplot")

  let x = @[1, 2, 3, 4]
  let y = @[5.5, 7.6, 11.1, 6.5]

  discard plt.figure()
  discard plt.plot(x, y)
  discard plt.show()



proc makePlot*(arr: seq[Rect], base: Rect, file: string){.discardable.}=
  var selfArr = arr
  var baseX: int = base.p0.x
  var baseY: int = base.p0.y
  var ax: PyObject
  let plt = pyImport("matplotlib.pyplot")
  let patch = pyImport("matplotlib.patches")
  discard plt.figure()
  ax = plt.axes()
  
  discard ax.add_patch(patch.Rectangle(xy=(baseX, baseY), width=base.w, height=base.h, fc = "b", ec="#000000", fill=false))

  for rct in selfArr:
    discard ax.add_patch(patch.Rectangle(xy=(rct.p0.x, rct.p0.y), width=rct.w, height=rct.h, fc = "b", ec="#000000", fill=true))
    #discard plt.text(rct.p0.x, rct.p0.y, $rct.index)
    #discard plt.text(rct.p0.x, rct.p0.y, fmt"{toMMFloat(rct.w)} x {toMMFloat(rct.h)}")

  discard plt.axis("scaled")
  discard ax.set_aspect("equal")
  discard plt.savefig(file)

  discard plt.close()
  
  