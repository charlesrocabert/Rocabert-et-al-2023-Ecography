#!/usr/bin/env Rscript
# coding: utf-8

suppressWarnings(library("ggplot2"))
suppressWarnings(library("cowplot"))

### Plot the number of jumps through time ###
plot_nb_jumps <- function()
{
  d1 = read.table("3_best_models/1-isotropic/output/lineage_tree.txt", h=T, sep=" ")
  d2 = read.table("3_best_models/2-human_activity/output/lineage_tree.txt", h=T, sep=" ")
  d3 = read.table("3_best_models/3-road_network/output/lineage_tree.txt", h=T, sep=" ")
  d4 = read.table("3_best_models/4-combined/output/lineage_tree.txt", h=T, sep=" ")
  t1 = as.data.frame(table(d1[,c("repetition", "iteration")]))
  t2 = as.data.frame(table(d2[,c("repetition", "iteration")]))
  t3 = as.data.frame(table(d3[,c("repetition", "iteration")]))
  t4 = as.data.frame(table(d4[,c("repetition", "iteration")]))
  names(t1) = c("Repetition", "Timestep", "Count")
  names(t2) = c("Repetition", "Timestep", "Count")
  names(t3) = c("Repetition", "Timestep", "Count")
  names(t4) = c("Repetition", "Timestep", "Count")
  p = ggplot() +
    scale_color_brewer(palette = "BrBG") +
    scale_fill_brewer(palette = "BrBG") +
    geom_smooth(data=t1, aes(x=as.numeric(Timestep), y=as.numeric(Count), color="1) Isotropic"), se=F) +
    geom_smooth(data=t2, aes(x=as.numeric(Timestep), y=as.numeric(Count), color="2) Human activity"), se=F) +
    geom_smooth(data=t3, aes(x=as.numeric(Timestep), y=as.numeric(Count), color="3) Road network"), se=F) +
    geom_smooth(data=t4, aes(x=as.numeric(Timestep), y=as.numeric(Count), color="4) Combined"), se=F) +
    labs(colour="Model") +
    xlab("Simulation time (years)") +
    ylab("Mean number of\ndispersal events") +
    ggtitle("Mean number of dispersal events through time") +
    theme_classic()
  return(p)
}

### Plot the number of estimated colonies through time ###
plot_nb_estimated_colonies <- function()
{
  d1 = read.table("5_models_complete_evaluation/1-isotropic/complete_evaluation_all.txt", h=T, sep=" ")
  d2 = read.table("5_models_complete_evaluation/2-human_activity/complete_evaluation_all.txt", h=T, sep=" ")
  d3 = read.table("5_models_complete_evaluation/3-road_network/complete_evaluation_all.txt", h=T, sep=" ")
  d4 = read.table("5_models_complete_evaluation/4-combined/complete_evaluation_all.txt", h=T, sep=" ")
  p  = ggplot() +
    scale_color_brewer(palette = "BrBG") +
    scale_fill_brewer(palette = "BrBG") +
    geom_point(data=d1[d1$rep==1,], aes(x=t, y=nb_colonies, color="1) Isotropic", shape="1) Isotropic")) +
    geom_point(data=d2[d2$rep==1,], aes(x=t, y=nb_colonies, color="2) Human activity", shape="2) Human activity")) +
    geom_point(data=d3[d3$rep==1,], aes(x=t, y=nb_colonies, color="3) Road network", shape="3) Road network")) +
    geom_point(data=d4[d4$rep==1,], aes(x=t, y=nb_colonies, color="4) Combined", shape="4) Combined")) +
    geom_hline(yintercept=81, lty=2) +
    annotate(geom="text", hjust=0, x=1, y=78, label="Number of observed colonies") +
    labs(colour="Model", shape="Model") +
    xlab("Simulation time (years)") +
    ylab("Estimated number\nof colonies") +
    ggtitle("Number of estimated colonies through time") +
    theme_classic()
  return(p)
}


##################
#      MAIN      #
##################

args    = commandArgs(trailingOnly = TRUE)
WORKDIR = args[1]
setwd(WORKDIR)

#----------------------#
# 1) Build the figures #
#----------------------#
p1 = plot_nb_jumps()
p2 = plot_nb_estimated_colonies()
p  = plot_grid(p1, p2, labels=c("(a)", "(b)"))
ggsave("figures/Figure4_SupportingInformation4.pdf", p, width=11, height=3.8, units="in")

