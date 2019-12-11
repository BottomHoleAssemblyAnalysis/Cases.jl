using BHAtp, Statistics

ProjDir = @__DIR__
!isdir(joinpath(ProjDir, "plots")) && mkdir(joinpath(ProjDir, "plots"))

# Actual data

incs = 45:5:55
wobs = 20:20:60
tpf = DataFrame()
for i in wobs
  for j in incs
    append!(tpf, DataFrame(incl=j, wob=i))
  end
end
tpf[!, :tp] = [1.55, 1.70, 1.85, 1.65, 1.83, 2.00, 1.75, 1.95, 2.15]
tpf[!, :ft] = [2200, 2400, 2600, 2400, 2600, 2800, 2650, 2750, 2950]

actual = DataFrame(
  incls = [49.75, 50.75, 51.50, 52.80, 54, 55],
  atp = [1.05, 1.07, 1.20, 1.15, 1.60, 1.22]
)

name = "figure_07"

figure_03 = @pgf GroupPlot({ 
    group_style = { 
      group_size = "1 by 1",
      vertical_sep = "0pt",
      xticklabels_at = "edge bottom"
    }
  },
  Axis({
      height = "6cm", width = " 8cm", 
      xmin = 42, xmax = 56,
      ymin = 0, ymax = 2.5,
      grid = "major",
      xlabel = "Inclination [°]", 
      ylabel = "TP [°/100ft]",
      title = "Figure 7:Actual vs. Isotropic TP",
      legend_pos = "south west", 
    },
    Plot({ color="blue", mark = "." }, 
      Table(tpf.incl[1:3], tpf.tp[1:3])),
    LegendEntry("TP wob=20"),
    Plot({ color="gray", mark = "." }, 
      Table(tpf.incl[4:6], tpf.tp[4:6])),
    LegendEntry("TP wob=40"),
    Plot({ color="green", mark = "." }, 
      Table(tpf.incl[7:9], tpf.tp[7:9])),
    LegendEntry("TP wob=60"),
    Plot({ thick, color="black", mark = "+", }, 
      Table(actual.incls, actual.atp)),
    LegendEntry("TP, actual")),
    LegendEntry("RPM"))

savefig(joinpath(ProjDir, "plots", name), figure_03, ProjDir)
