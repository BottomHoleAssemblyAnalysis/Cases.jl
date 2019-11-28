using BHAtp, Statistics

ProjDir = @__DIR__
!isdir(joinpath(ProjDir, "plots")) && mkdir(joinpath(ProjDir, "plots"))

ProjName = split(ProjDir, "/")[end]
bhaj = BHAtp.BHAJ(ProjName, ProjDir)
bhaj.ratio = 0.5

segs = [
	# Element type,  Material,    Length,     OD,   ID,  fc
	(:bit,           :steel,        0.00,   2.75,  9.0,  0.0),
	(:collar,        :steel,       45.00,   2.75,  7.0,  0.0),
	(:stabilizer,    :steel,        0.00,   2.75,  9.0,  0.0),
	(:pipe,          :steel,       30.00,   2.75,  7.0,  0.0),
	(:stabilizer,    :steel,        0.00,   2.75,  9.0,  0.0),
	(:pipe,          :steel,       90.00,   2.75,  7.0,  0.0),
	(:stabilizer,    :steel,        0.00,   2.75,  9.0,  0.0),
	(:pipe,          :steel,      100.00,   2.75,  7.0,  0.0)
]

traj = [
	#Heading,  Diameter
	( 60.0,      9.0)
]

wobs = 20:10:40
incls = 20:10:50  # Or e.g. incls = [5 10 20 30 40 45 50]

@time bhaj(segs, traj, wobs, incls)

display("Fetch tp=false, wob=40, incl@bit=20 solution:")
df,df_tp = show_solution(ProjDir, 40, 20, show=false, tp=false)
df[:,[2; 5:6; 9:12]] |> display
println()

println("Fetch tp=true, wob=40, incl@bit=20 solution:")
df,df_tp = show_solution(ProjDir, 40, 20, show=false);
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
    sf = @linq df |> where(:dtb .== 45)
    append!(sfs, sf.fx)
  end
end

# Simulated actual tps

noise = 0.1rand(2*length(incls))
noise = noise .- mean(noise)
actual = DataFrame(
  incls = LinRange(15.0, 50.0, 2*length(incls)),
  atp = LinRange(-2.7, -4.5, 2*length(incls)) .+ noise
)

# Function to simulated formation correction factors

intp_fcf  = LinearInterpolation(LinRange(0.0, 3000, 10), LinRange(0.63, 0.72, 10));
ctp = tpf.tp .- intp_fcf.(sfs)

result_df = DataFrame(
  wob = sort(repeat(wobs, length(incls))),
  incl = repeat(incls, length(wobs)),
  tp = tpf.tp,
  side_force = sfs,
  corr_factor = intp_fcf.(sfs),
  corr_tp = ctp
);
result_df |> display
println()

name = "case_01a"

case_01a = @pgf GroupPlot({ 
  group_style = { 
    group_size = "1 by 1",
    vertical_sep = "0pt",
    xticklabels_at = "edge bottom" }
  },
  Axis({ height = "6cm", width = "8cm", xlabel = "Inclination [°]", 
      ylabel = "TP [°/100ft]", title = "Actual vs. Corrected TP" },
      Plot({ color="blue", mark = "*" }, Table(incls, result_df.tp[9:12])),
      LegendEntry("Predicted"),
      Plot({ color="red", mark = "*" }, Table(incls, result_df.corr_tp[9:12])),
      LegendEntry("Corrected"),
      Plot({ thick, color="black", mark = "+" }, Table(actual.incls, actual.atp)),
      LegendEntry("Actual")))

savefig(joinpath(ProjDir, "plots", name), case_01a, ProjDir)

name = "case_01b"

case_01b = @pgf GroupPlot({ 
  group_style = { 
    group_size = "1 by 3",
    vertical_sep = "0pt",
    xticklabels_at = "edge bottom" }
  },
  Axis({ 
        height = "6cm", width = "8cm",
        ylabel = "TP [°/100ft]", title = "TP and Formatioin Correction (ΔTP)"
      },
      Plot({ color="red", mark = "*" }, Table(incls, tpf.tp[1:4])),
      LegendEntry("WOB 20"),
      Plot({ color="blue", mark = "+" }, Table(incls, tpf.tp[5:8])),
      LegendEntry("WOB 30"),
      Plot({ color="green", mark = "o" }, Table(incls, tpf.tp[9:12])),
      LegendEntry("WOB 40")),
    Axis({
          height = "6cm", width = "8cm", 
          ylabel = "Sideforce NBS"
        },
        Plot({ color="red", mark = "*", title ="TP" }, Table(incls, sfs[1:4])),
        LegendEntry("WOB 20"),
        Plot({ color="blue", mark = "+" }, Table(incls, sfs[5:8])),
        LegendEntry("WOB 30"),
        Plot({ color="green", mark = "o" }, Table(incls, sfs[9:12])),
        LegendEntry("WOB 40")),
   Axis({ height = "6cm", width = "8cm", xlabel = "Inclination [°]", 
      ylabel = "ΔTP [°/100ft]" },
      Plot({ color="red", mark = "*" }, Table(incls, result_df.corr_factor[1:4])),
      LegendEntry("WOB 20"),
      Plot({ color="blue", mark = "+" }, Table(incls, result_df.corr_factor[5:8])),
      LegendEntry("WOB 30"),
      Plot({ color="green", mark = "o" }, Table(incls, result_df.corr_factor[9:12])),
      LegendEntry("WOB 40")))

savefig(joinpath(ProjDir, "plots", name), case_01b, ProjDir)