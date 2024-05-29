#!/usr/bin/env Rscript
# coding: utf-8

suppressWarnings(library("ggplot2"))
suppressWarnings(library("ggpubr"))
suppressWarnings(library("sf"))

### Plot best scenarios invasion patterns ###
plot_invasion_map <- function( filename, title, xintro, yintro, year )
{
	#--------------------------#
	# 1) Load and prepare data #
	#--------------------------#
  urban          = st_read("resources/input_files/UMZ2006_cut2.shx")
  coordCorrec    = c(st_bbox(urban)[1]+1, st_bbox(urban)[2]+1)
	data           = read.table(filename, h=T)
	data_yobs      = data[data$y_obs>0.0,]
	data_nobs      = data[data$y_obs==0.0&data$n_obs>0.0,]
	data_sim       = data[data$p_sim>0.0,]
	data_sim       = data_sim[order(data_sim$p_sim),]
	RG             = range(data_sim$p_sim)
	#--------------------------#
	# 2) Create figure         #
	#--------------------------#
	p = ggplot() +
	  geom_sf(data=st_geometry(urban), color=NA, fill="black") +
	  geom_tile(data=data_sim, aes(x=x+coordCorrec[1], y=y+coordCorrec[2], fill=p_sim), alpha=0.7, colour="grey50") +
	  scale_fill_gradient2(low="#440154FF", mid="#21908CFF", high="#FDE725FF", trans="log10", midpoint=-1.5, limits=RG) +
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

### Generate figures of spread history ###
plot_spread_history <- function()
{
  urban = st_read("resources/input_files/UMZ2006_cut2.shx")
	Tvec = seq(0,25)
	for (t in Tvec)
	{
		##########################
	  f1 = f2 = f3 = f4 = ""
	  if (t < 25)
	  {
	    f1 = paste("3_best_models/1-isotropic/output/state_",t,".txt",sep="")
	    f2 = paste("3_best_models/2-human_activity/output/state_",t,".txt",sep="")
	    f3 = paste("3_best_models/3-road_network/output/state_",t,".txt",sep="")
	    f4 = paste("3_best_models/4-combined/output/state_",t,".txt",sep="")
	  }
	  ##########################
	  if (t == 25)
	  {
	    f1 = "3_best_models/1-isotropic/output/final_state.txt"
	    f2 = "3_best_models/2-human_activity/output/final_state.txt"
	    f3 = "3_best_models/3-road_network/output/final_state.txt"
	    f4 = "3_best_models/4-combined/output/final_state.txt"
	  }
		##########################
	  p1 = plot_invasion_map(f1, "Isotropic model", 20026.56, 73514.26, t)
	  p2 = plot_invasion_map(f2, "Human activity model", 29673.02, 58030.17, t)
	  p3 = plot_invasion_map(f3, "Road network model", 31238.47, 66451.83, t)
	  p4 = plot_invasion_map(f4, "Combined model", 60764.4, 38009.8, t)
	  p  = ggarrange(p1, p2, p3, p4, ncol=2, nrow=2, common.legend=TRUE, legend="none", align="hv")
		#############
	  image_name = ""
		if (t < 10)
		{
		  cat(paste0("> Create figure ", t))
			image_name = paste0("minigif/0", t)
		}
		if (t >= 10)
		{
		  cat(paste0("> Create figure ", t))
		  image_name = paste0("minigif/" ,t)
		}
	  #ggsave(p, filename=paste0(image_name, ".jpg"), width=6.5*0.5, height=7.6*0.5, units="in", bg="white", dpi=150)#, compression="lzw")
	  ggsave(p, filename=paste0(image_name, ".png"), bg="white", width = 6.5, height = 7.6, dpi = 80)
	}
}


##################
#      MAIN      #
##################

#args    = commandArgs(trailingOnly = TRUE)
#WORKDIR = args[1]
WORKDIR = "/Users/charlesrocabert/git/MoRIS-development/Rocabert-et-al-2022"
setwd(WORKDIR)

plot_spread_history()

