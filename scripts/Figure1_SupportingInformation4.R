#!/usr/bin/env Rscript
# coding: utf-8

suppressWarnings(library("ggplot2"))
suppressWarnings(library("cowplot"))
suppressWarnings(library("sf"))

### Plot the scenario invasion pattern ###
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
    theme_classic() +
    theme(plot.title=element_text(hjust = -0.5))
  return(p)
}

### Plot the distribution of jump sizes ###
plot_jump_size_distribution <- function( filename )
{
  data = read.table(filename, h=T, sep=" ")
  p = ggplot(data, aes(x=(euclidean_dist), after_stat(density))) +
    scale_color_brewer(palette = "BrBG") +
    scale_fill_brewer(palette = "BrBG") +
    geom_histogram() +
    xlim(1,90000) +
    xlab("Dispersal event distance (meters)") +
    ylab("Density") +
    ggtitle("Distribution of dispersal event distances") +
    theme_classic()
  return(p)
}

### Plot the number of jumps through time ###
plot_nb_jumps <- function( filename )
{
  data        = read.table(filename, h=T, sep=" ")
  tabl        = as.data.frame(table(data[,c("repetition", "iteration")]))
  names(tabl) = c("Repetition", "Timestep", "Count")
  p = ggplot(tabl, aes(x=as.numeric(Timestep), y=as.numeric(Count))) +
    geom_smooth(se=F, color="black") +
    xlab("Simulation time (years)") +
    ylab("Mean number of\ndispersal events") +
    ggtitle("Mean number of dispersal events") +
    theme_classic()
  return(p)
}

### Plot the number of estimated colonies through time ###
plot_nb_estimated_colonies <- function( filename )
{
  data = read.table(filename, h=T, sep=" ")
  p    = ggplot(data[data$rep==1,], aes(x=t, y=nb_colonies)) +
    scale_color_brewer(palette = "BrBG") +
    scale_fill_brewer(palette = "BrBG") +
    geom_point() +
    geom_hline(yintercept=81, lty=2) +
    annotate(geom="text", hjust=0, x=1, y=76, label="Number of observed colonies") +
    xlab("Simulation time (years)") +
    ylab("Estimated number\nof colonies") +
    ggtitle("Number of estimated colonies") +
    theme_classic()
  return(p)
}

### Plot the road category weights ###
plot_road_weights <- function()
{
  w = data.frame(Category=c("I", "II", "III", "IV"), Weight=c(0.552323, 0.906278, 0.0759662, 0.00896529)/sum(c(0.552323, 0.906278, 0.0759662, 0.00896529)))
  p = ggplot(w, aes(x=Category, y=Weight)) +
    geom_bar(stat="identity") +
    #coord_flip() +
    xlab("Road category") +
    ylab("Normalized weights") +
    ggtitle("Normalized road category weights") +
    theme_classic()
  return(p)
}


##################
#      MAIN      #
##################

options(show.error.messages=FALSE, warn=-1)
args    = commandArgs(trailingOnly = TRUE)
WORKDIR = args[1]

setwd(WORKDIR)

#----------------------#
# 1) Build the figures #
#----------------------#
p1 = plot_invasion_map("3_best_models/3-road_network/output/final_state.txt", "Invasion geographical pattern", 31238.47, 66451.83)
p2 = plot_road_weights()
p3 = plot_jump_size_distribution("3_best_models/3-road_network/output/lineage_tree.txt")
p4 = plot_nb_jumps("3_best_models/3-road_network/output/lineage_tree.txt")
p5 = plot_nb_estimated_colonies("5_models_complete_evaluation/3-road_network/complete_evaluation_all.txt")

pl = plot_grid(p1, p2, ncol=1, labels=c("(a)","(b)"))
pr = plot_grid(p3, p4, p5, ncol=1, labels=c("(c)","(d)","(e)"))
p  = plot_grid(pl, pr, ncol=2)

ggsave("figures/Figure1_SupportingInformation4.pdf", p, width=9, height=7.6, units="in")

