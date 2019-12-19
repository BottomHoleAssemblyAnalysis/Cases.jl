using BHAtp, Statistics

ProjDir = @__DIR__
!isdir(joinpath(ProjDir, "plots")) && mkdir(joinpath(ProjDir, "plots"))

ProjName = split(ProjDir, "/")[end]
bhaj = BHAtp.BHAJ(ProjName, ProjDir)
bhaj.ratio = 2.5

segs = [
	# Element type,  Material,    Length,     ID,   OD,    fc
	(:bit,           :steel,        0.00,   2.000, 12.250,  0.0),
  (:collar,        :steel,        1.00,   2.000,  7.875,  0.0),
  (:collar,        :steel,        1.85,   2.750,  7.875,  0.0),
	(:stabilizer,    :steel,        0.00,   2.750, 12.250,  0.0),
  (:collar,        :steel,        3.90,   2.750,  7.875,  0.0),
	(:collar,        :monel,       28.51,   2.750,  8.000,  0.0),
  (:collar,        :monel,        1.77,   3.000,  8.000,  0.0),
  (:stabilizer,    :monel,        0.00,   3.000, 12.250,  0.0),
  (:collar,        :monel,        3.78,   3.000,  8.000,  0.0),
	(:collar,        :monel,        2.50,   3.000,  8.875,  0.0),
  (:collar,        :monel,       25.00,   5.500,  8.875,  0.0),
  (:stabilizer,    :monel,        0.00,   5.500, 12.250,  0.0),
  (:collar,        :monel,       14.23,   5.500,  8.875,  0.0),
  (:collar,        :monel,        2.46,   3.000,  8.875,  0.0),
  (:collar,        :monel,       29.68,   2.750,  8.313,  0.0),
  (:collar,        :monel,        1.45,   3.000,  8.000,  0.0),
  (:stabilizer,    :monel,        0.00,   3.000, 12.250,  0.0),
  (:collar,        :monel,        3.75,   3.000,  8.000,  0.0),
  (:collar,        :monel,       29.62,   2.750,  8.313,  0.0),
  (:collar,        :steel,      218.39,   2.750,  8.000,  0.0),
  (:collar,        :steel,       31.60,   2.750,  8.000,  0.0)
]

traj = [
	#Heading,  Diameter
	( 60.0,      12.250)
]

incls = 45:5:55
wobs = 20:20:60

@time bhaj(segs, traj, wobs, incls)

display("Fetch tp=false, wob=40, incl@bit=50 solution:")
df,df_tp = show_solution(ProjDir, 40, 50, show=false, tp=false)
df[1:25,[2; 5:6; 9:12]] |> display
println()

println("Fetch tp=true, wob=40, incl@bit=50 solution:")
df,df_tp = show_solution(ProjDir, 40, 50, show=false);
df[1:25,[2; 5:6; 9:12]] |> display
println()

tpf = create_final_tp_df(ProjDir, wobs, incls; ofu=false)
tpf |> display
println()

# Collect computed side forces on NBS @ 45ft

sfs = []
for wob in wobs
  for incl in incls
    df, df_tp = show_solution(ProjDir, wob, incl, show=false);
    sf = @linq df |> where(:dtb .== 2.85)
    append!(sfs, sf.fx)
  end
end

# Actual tps

actual = DataFrame(
  incls = [49.75, 50.75, 51.50, 52.80, 54, 55],
  atp = [1.05, 1.07, 1.20, 1.15, 1.60, 1.22]
)

name = "figure_07_1"

figure_07_1 = @pgf GroupPlot({ 
    group_style = { 
      group_size = "1 by 1",
      vertical_sep = "0pt",
      xticklabels_at = "edge bottom"
    }
  },
  Axis({
      height = "6cm", width = " 8cm", 
      xmin = 42, xmax = 56,
      ymin = 0.0, ymax = 2.5,
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
    LegendEntry("TP, actual")))

savefig(joinpath(ProjDir, "plots", name), figure_07_1, ProjDir)


