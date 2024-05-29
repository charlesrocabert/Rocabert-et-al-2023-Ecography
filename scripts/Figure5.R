#!/usr/bin/env Rscript
# coding: utf-8

suppressWarnings(library("ggplot2"))
suppressWarnings(library("ggpubr"))
suppressWarnings(library("sf"))

### Plot best models invasion patterns ###
plot_invasion_map <- function( filename, title, xintro, yintro )
{
	#--------------------------#
	# 1) Load and prepare data #
	#--------------------------#
	urban       = st_read("resources/input_files/UMZ2006_cut2.shx")
	coordCorrec = c(st_bbox(urban)[1]+1, st_bbox(urban)[2]+1)
	data        = read.table(filename, h=T)
	data_yobs   = data[data$y_obs>0.0,]
	data_nobs   = data[data$y_obs==0.0&data$n_obs>0.0,]
	data_sim    = data[data$p_sim>0.0,]
	data_sim    = data_sim[order(data_sim$p_sim),]
	RG          = range(data_sim$p_sim)
	#--------------------------#
	# 2) Create figure         #
	#--------------------------#
	p = ggplot() +
	  geom_sf(data=st_geometry(urban), color=NA, fill="black") +
  	geom_tile(data=data_sim, aes(x=x+coordCorrec[1], y=y+coordCorrec[2], fill=p_sim), alpha=0.7, colour="grey50") +
	  scale_fill_gradient2(low="turquoise4", mid="brown", high="yellow", trans="log10", midpoint=-1.5, limits=RG) +
	  #geom_vline(xintercept=xintro+coordCorrec[1], linetype=2) +
	  #geom_hline(yintercept=yintro+coordCorrec[2], linetype=2) +
		geom_point(aes(x=xintro+coordCorrec[1], y=yintro+coordCorrec[2]), shape=1, color="red", size=2, stroke=1) +
  	labs(fill="Simulated\nprobability\nof presence") +
  	xlab("Longitude") +
  	ylab("Latitude") +
  	ggtitle(title) +
  	theme_classic()
	return(p)
}


##################
#      MAIN      #
##################

args    = commandArgs(trailingOnly = TRUE)
WORKDIR = args[1]
setwd(WORKDIR)

p1 = plot_invasion_map("3_best_models/1-isotropic/output/final_state.txt", "Isotropic model", 20026.56, 73514.26)
p2 = plot_invasion_map("3_best_models/2-human_activity/output/final_state.txt", "Human activity model", 29673.02, 58030.17)
p3 = plot_invasion_map("3_best_models/3-road_network/output/final_state.txt", "Road network model", 31238.47, 66451.83)
p4 = plot_invasion_map("3_best_models/4-combined/output/final_state.txt", "Combined model", 60764.4, 38009.8)
p  = ggarrange(p1, p2, p3, p4, ncol=2, nrow=2, common.legend = TRUE, legend="right", labels=c("(a)","(b)","(c)","(d)"))
ggsave("figures/Figure5.pdf", p, width=9, height=7.6, units="in")

