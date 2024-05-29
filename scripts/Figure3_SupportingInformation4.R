#!/usr/bin/env Rscript
# coding: utf-8

suppressWarnings(library("ggplot2"))
suppressWarnings(library("cowplot"))

### Plot the distribution of jump sizes ###
plot_jump_size_distribution <- function( filename, title )
{
  data = read.table(filename, h=T, sep=" ")
  p = ggplot(data, aes(x=(euclidean_dist), after_stat(density))) +
    scale_color_brewer(palette = "BrBG") +
    scale_fill_brewer(palette = "BrBG") +
    geom_histogram() +
    xlim(1,90000) +
    xlab("Dispersal event distance (meters)") +
    ylab("Density") +
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

#---------------------#
# 3) Build the figure #
#---------------------#
p1 = plot_jump_size_distribution("3_best_models/1-isotropic/output/lineage_tree.txt", "Isotropic model")
p2 = plot_jump_size_distribution("3_best_models/2-human_activity/output/lineage_tree.txt", "Human activity model")
p3 = plot_jump_size_distribution("3_best_models/3-road_network/output/lineage_tree.txt", "Road network model")
p4 = plot_jump_size_distribution("3_best_models/4-combined/output/lineage_tree.txt", "Combined model")
p  = plot_grid(p1, p2, p3, p4, labels=c("(a)","(b)","(c)","(d)"))
ggsave("figures/Figure3_SupportingInformation4.pdf", p, width=8.3, height=7, units="in")

