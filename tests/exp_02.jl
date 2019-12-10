
tpf = DataFrame(
  incl = 30:5:60,
  tp = 5.2:0.1:5.8
)

actual = DataFrame(
  incls = [40.0, 42.3, 44.0, 44.65, 45.7, 47.25, 49.5],
  atp = [2.55, 2.65, 0.4, 1.15, 1.18, 2.15, 2.35],
  rpm = [120, 120, 60, 70, 80, 80, 140]
)

exp_02 = @pgf TikzPicture(
    Axis({
	    	height = "6cm", width = "8cm",
	    	xmin = 0, xmax = 60,
	    	ymin = 0, ymax = 6,
	        axis_y_line = "left",
	        xlabel = "Inclination [°]", 
      		ylabel = "TP [°/100ft]",
      		title = "Actual vs. Isotropic TP",
      		legend_pos = "south west",
		},
	    Plot({ color="blue", mark = "." }, 
	      Table(tpf.incl[1:7], tpf.tp[1:7])),
	    LegendEntry("TP, wob=30")),
   Axis({
	    	height = "6cm", width = "8cm",
	    	xmin = 0, xmax = 60,
	    	ymin = 0, ymax = 150,
	    	hide_x_axis,
	        axis_y_line = "right",
      		ylabel = "RPM [revs/min]",
	    },
	    Plot({ color="red", mark = "." }, 
	      Table(actual.incls, actual.rpm)))
)

print_tex(exp_02)

savefig("exp_02", exp_02, @__DIR__)
