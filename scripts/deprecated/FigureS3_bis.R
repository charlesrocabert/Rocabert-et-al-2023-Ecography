#!/usr/bin/env Rscript
# coding: utf-8

suppressWarnings(library("ggplot2"))
suppressWarnings(library("cowplot"))
suppressWarnings(library("ggpubr"))

### Load the evaluation metrics data ###
load_evaluation_metrics <- function()
{
  #------------------------------------#
  # 1) Load data                       #
  #------------------------------------#
  isotropic        = read.table("4_models_evaluation/1-isotropic/score_distribution.txt", sep=" ", h=T)
  human_activity   = read.table("4_models_evaluation/2-human_activity/score_distribution.txt", sep=" ", h=T)
  road_network     = read.table("4_models_evaluation/3-road_network/score_distribution.txt", sep=" ", h=T)
  combined         = read.table("4_models_evaluation/4-combined/score_distribution.txt", sep=" ", h=T)
  N_isotropic      = length(isotropic[,1])
  N_human_activity = length(human_activity[,1])
  N_road_network   = length(road_network[,1])
  N_combined       = length(combined[,1])
  #------------------------------------#
  # 2) Merge dataframes                #
  #------------------------------------#
  data        = as.data.frame(rbind(isotropic, human_activity, road_network, combined))
  names(data) = names(isotropic)
  data$Model  = c(rep("1) Isotropic", N_isotropic), rep("2) Human activity", N_human_activity), rep("3) Road network", N_road_network), rep("4) Combined", N_combined))
  #------------------------------------#
  # 3) Add sensitivity and specificity #
  #------------------------------------#
  data$Sensitivity = data$TPR
  data$Specificity = 1-data$FPR
  return(data)
}

### Plot score distribution through models ###
plot_score <- function( data, my_comparisons, score_name, score_label, pvalue_size )
{
  p = ggplot(data, aes_string(x="Model", y=score_name, fill="Model")) +
    scale_fill_brewer(palette = "BrBG") +
    geom_boxplot() +
    stat_compare_means(comparisons=my_comparisons, p.adjust.method="bonferroni", method='wilcox.test') +
    xlab("Model") +
    ylab(paste0(score_label, "\n(100 repetitions)")) +
    ggtitle(score_label) +
    theme_classic() +
    theme(axis.text.x=element_blank())
  p$layers[[2]]$aes_params$textsize = pvalue_size
  return(p)
}

### Plot the distributions of evaluation metric thresholds ###
plot_evaluation_threshold <- function()
{
  data = load_evaluation_metrics()
  ###############################
  my_comparisons = list(c("1) Isotropic", "2) Human activity"), c("1) Isotropic", "3) Road network"), c("1) Isotropic", "4) Combined"), c("2) Human activity", "3) Road network"), c("2) Human activity", "4) Combined"), c("3) Road network", "4) Combined"))
  ###############################
  p1 = plot_score(data, my_comparisons, "d_th", "th(d)", 2.5)
  p2 = plot_score(data, my_comparisons, "ACC_th", "th(ACC)", 2.5)
  p3 = plot_score(data, my_comparisons, "F1_th", "th(F1)", 2.5)
  p4 = plot_score(data, my_comparisons, "KAPPA_th", "th(Kappa)", 2.5)
  p5 = plot_score(data, my_comparisons, "TSS_th", "th(TSS)", 2.5)
  ###############################
  p = plot_grid(p1, p2, p3, p4, p5, ncol=2, labels=c("(a)","(b)","(c)","(d)","(e)"))
  return(p)
}


##################
#      MAIN      #
##################

args    = commandArgs(trailingOnly = TRUE)
WORKDIR = args[1]
setwd(WORKDIR)

p = plot_evaluation_threshold()
ggsave("figures/FigureS3_bis.pdf", p, width=10, height=9.2, units="in")

