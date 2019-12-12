using BHAtp, Statistics

ProjDir = @__DIR__
!isdir(joinpath(ProjDir, "plots")) && mkdir(joinpath(ProjDir, "plots"))

# Actual data

incs = [5,10, 20, 30, 40, 50]
tpf = DataFrame(incl=incs)
tpf[!, :tp] = [1.95, 2.70, 3.60, 4.30, 4.80, 5.05]

actual = DataFrame(
  incls = [4, 6.5, 7.5, 12, 13, 15,17.5, 20.1, 23, 27, 30.5, 34.4, 40.1, 45],
  atp = [1.75, 1.8, 1.95, 2.05, 2.45, 2.5, 2.6, 2.7, 3, 3.1, 3.4, 3.8, 3.8, 4]
)

fcf = DataFrame(
  incl = [5, 10, 20, 30, 40, 50],
  ft = [750, 1200, 2000, 2500, 3000, 3500],
  fcf = [0.18, 0.7, 0.9, 0.95, 1, 0.95]
)

name = "figure_08"

figure_08 = @pgf GroupPlot({ 
    group_style = { 
      group_size = "1 by 2",
      vertical_sep = "0pt",
      xticklabels_at = "edge bottom"
    }
  },
  Axis({
      height = "6cm", width = " 8cm", 
      xmin = 0, xmax = 55,
      ymin = 0, ymax = 5,
      grid = "major",
      xlabel = "Inclination [°]", 
      ylabel = "TP [°/100ft]",
      title = "Figure 8: Actual vs. TP",
      legend_pos = "south east", 
    },
    Plot({ color="blue", mark = "." }, 
      Table(tpf.incl, tpf.tp)),
    LegendEntry("Isotropic TP"),
    Plot({ color="green", mark = "." }, 
      Table(tpf.incl, tpf.tp - fcf.fcf)),
    LegendEntry("Predicted TP"),
    Plot({ thick, color="black", mark = "+", }, 
      Table(actual.incls, actual.atp)),
    LegendEntry("TP, actual")),
    LegendEntry("RPM"),
  Axis({
        height = "6cm", width = "8cm", 
        ylabel = "Sideforce NBS",
        xmin = 0, xmax = 55,
        ymin = 0, ymax = 4000,
        grid = "major",
        xlabel = "Inclination [°]", 
        ylabel = "Sideforce",
        legend_pos = "south east", 
      },
      Plot({ color="red", mark = "*", title ="TP" },
        Table(fcf.incl, fcf.ft)),
      LegendEntry("sideforce"),
  )
)

savefig(joinpath(ProjDir, "plots", name), figure_08, ProjDir)
