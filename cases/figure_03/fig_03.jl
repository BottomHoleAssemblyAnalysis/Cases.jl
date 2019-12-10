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

# Collect computed side forces on NBS @ 45ft

sfs = []
for wob in wobs
  for incl in incls
    df, df_tp = show_solution(ProjDir, wob, incl, show=false);
    sf = @linq df |> where(:dtb .== 5.68)
    append!(sfs, sf.fx)
  end
end

# Actual tps

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
