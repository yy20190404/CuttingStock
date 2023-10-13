import nimpy # pltからの.呼出でnimpyが要る
import rect


proc makePlot*(arr: seq[Rect], base: Rect, file: string){.discardable.}=
  # Plot image from located rectangle data
  var 
    selfArr = arr
    baseX: float = base.p0.x
    baseY: float = base.p0.y
    ax: PyObject
  let 
    plt = pyImport("matplotlib.pyplot")
    patch = pyImport("matplotlib.patches")
  discard plt.figure()
  ax = plt.axes()
  
  discard ax.add_patch(patch.Rectangle(xy=(baseX, baseY), width=base.w, height=base.h, fc = "b", ec="#000000", fill=false))

  for rct in selfArr:
    discard ax.add_patch(patch.Rectangle(xy=(rct.p0.x, rct.p0.y), width=rct.w, height=rct.h, fc = "b", ec="#000000", fill=true))

  discard plt.axis("scaled")
  discard ax.set_aspect("equal")
  discard plt.savefig(file)

  discard plt.close()
  
  