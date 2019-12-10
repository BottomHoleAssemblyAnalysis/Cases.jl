using BHAtp, Statistics

ProjDir = @__DIR__
!isdir(joinpath(ProjDir, "plots")) && mkdir(joinpath(ProjDir, "plots"))

ProjName = split(ProjDir, "/")[end]
bhaj = BHAtp.BHAJ(ProjName, ProjDir)
bhaj.ratio = 0.5

segs = [
  # Element type,  Material,    Length,     ID,   OD,    fc
  (:bit,           :steel,        0.00,   2.000, 17.500,  0.0),
  (:collar,        :steel,        1.44,   2.000,  9.500,  0.0),
  (:collar,        :steel,        3.00,   3.000,  9.500,  0.0),
  (:collar,        :steel,        1.24,   2.938,  9.500,  0.0),
  (:stabilizer,    :steel,        0.00,   2.938, 17.500,  0.0),
  (:collar,        :steel,        4.04,   2.938,  9.500,  0.0),
  (:collar,        :monel,       37.45,   2.875,  9.500,  0.0),
  (:collar,        :monel,       27.09,   3.000,  9.625,  0.0),
  (:collar,        :monel,       30.01,   2.875,  9.500,  0.0),
  (:collar,        :steel,        1.87,   3.000,  9.500,  0.0),
  (:stabilizer,    :steel,        0.00,   3.000, 17.500,  0.0),
  (:collar,        :steel,        3.73,   3.000,  9.500,  0.0),
  (:collar,        :steel,       28.73,   2.875,  9.500,  0.0),
  (:collar,        :steel,        4.22,   3.000,  9.125,  0.0),
  (:collar,        :steel,       27.98,   2.750,  7.875,  0.0),
  (:collar,        :steel,       29.45,   2.875,  7.563,  0.0),
  (:collar,        :steel,       30.87,   2.875,  7.625,  0.0),
  (:collar,        :steel,       31.10,   2.750,  8.000,  0.0),
  (:collar,        :steel,       32.18,   3.000,  8.000,  0.0),
  (:collar,        :steel,       30.88,   2.750,  7.938,  0.0),
  (:collar,        :steel,        3.50,   2.750,  8.000,  0.0)
]

traj = [
  #Heading,  Diameter
  ( 60.0,      17.5)
  
]

wobs = 30:5:40
incls = 30:5:60  # Or e.g. incls = [5 10 20 30 40 45 50]

@time bhaj(segs, traj, wobs, incls)

display("Fetch tp=false, wob=35, incl@bit=30 solution:")
df,df_tp = show_solution(ProjDir, 35, 30, show=false, tp=false)
df[:,[2; 5:6; 9:12]] |> display
println()

println("Fetch tp=true, wob=35, incl@bit=30 solution:")
df,df_tp = show_solution(ProjDir, 35, 30, show=false);
df[:,[2; 5:6; 9:12]] |> display
println()

tpf = create_final_tp_df(ProjDir, wobs, incls; ofu=false)
tpf |> display
println()

name = "figure_03a"

figure_03a = @pgf GroupPlot({ 
    group_style = { 
      group_size = "1 by 2",
      vertical_sep = "0pt",
      xticklabels_at = "edge bottom"
    }
  },
  Axis({ 
      height = "6cm", width = "8cm",
      ylabel = "TP [°/100ft]", title = "TP and Formatioin Correction (ΔTP)"
    },
    Plot({ color="red", mark = "*" }, Table(incls, tpf.tp[1:7])),
    LegendEntry("WOB 30"),
    Plot({ color="blue", mark = "+" }, Table(incls, tpf.tp[8:14])),
    LegendEntry("WOB 35"),
    Plot({ color="green", mark = "o" }, Table(incls, tpf.tp[15:21])),
    LegendEntry("WOB 40")
  ),
  Axis({
      height = "6cm", width = "8cm", 
      ylabel = "Sideforce NBS"
    },
    Plot({ color="red", mark = "*", title ="TP" }, Table(incls, tpf.ft[1:7])),
    LegendEntry("WOB 30"),
    Plot({ color="blue", mark = "+" }, Table(incls, tpf.ft[8:14])),
    LegendEntry("WOB 35"),
    Plot({ color="green", mark = "o" }, Table(incls, tpf.ft[15:21])),
    LegendEntry("WOB 40")
  )
)

savefig(joinpath(ProjDir, "plots", name), figure_03a, ProjDir)
