using BHAtp, Statistics

ProjDir = @__DIR__
!isdir(joinpath(ProjDir, "plots")) && mkdir(joinpath(ProjDir, "plots"))

actual = DataFrame(
  incls = [40.0, 42.3, 44.0, 44.65, 45.7, 47.25, 49.5],
  atp = [2.55, 2.65, 0.4, 1.15, 1.18, 2.15, 2.35],
)

rpm = DataFrame(
  incls = [35, 43.5,43.6,44.2,44.3,44.9, 45, 48,48.1, 55],
  rpm = [ 100,  100,  60,  60,  70,  70, 80, 80, 120,120]
)

name = "figure_03"

figure_03 = @pgf TikzPicture(
  Axis({
      height = "6cm", width = " 8cm", 
      xmin = 30, xmax = 90,
      ymin = 0, ymax = 6.2,
      axis_y_line = "left",
      xlabel = "Inclination [°]", 
      ylabel = "TP [°/100ft]",
      title = "Actual vs. Isotropic TP",
      legend_pos = "south east", 
    },
    Plot({ color="blue", mark = "." }, 
      Table(tpf.incl[1:7], tpf.tp[1:7])),
    LegendEntry("TP wob=30"),
    Plot({ color="gray", mark = "." }, 
      Table(tpf.incl[8:14], tpf.tp[8:14])),
    LegendEntry("TP wob=35"),
    Plot({ color="green", mark = "." }, 
      Table(tpf.incl[15:21], tpf.tp[15:21])),
    LegendEntry("TP wob=35"),
    Plot({ thick, color="black", mark = "+" }, 
      Table(actual.incls, actual.atp)),
    LegendEntry("Actual")),
  Axis({
      height = "6cm", width = " 8cm", 
      ymin = 0, ymax = 160, 
      xmin = 30, xmax = 90,
      hide_x_axis,
      axis_y_line = "right",
      ylabel = "RPM [revs/min]",
      legend_pos = "north east", 
    },
    Plot({ color="red", mark = "." }, 
      Table(rpm.incls, rpm.rpm)),
    LegendEntry("RPM")),
)

savefig(joinpath(ProjDir, "plots", name), figure_03, ProjDir)
