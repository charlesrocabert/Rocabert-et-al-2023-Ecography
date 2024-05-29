#!/usr/bin/env Rscript
# coding: utf-8

suppressWarnings(library("ggplot2"))
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
plot_score_with_p_values <- function( data, my_comparisons, score_name, score_label, pvalue_size )
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

### Plot score distribution through models ###
plot_score_with_letters <- function( data, my_comparisons, score_name, score_label, letters, colors, letters_pos )
{
  # letters_pos  = c(mean(data[data$Model=="1) Isotropic", score_name])+letters_shift,
  #                  mean(data[data$Model=="2) Human activity", score_name])+letters_shift,
  #                  mean(data[data$Model=="3) Road network", score_name])+letters_shift,
  #                  mean(data[data$Model=="4) Combined", score_name])+letters_shift)
  letters_size = 5
  p = ggplot(data, aes_string(x="Model", y=score_name)) + #, fill="Model")) +
    scale_fill_brewer(palette = "BrBG") +
    scale_color_brewer(palette = "BrBG") +
    geom_violin(aes(fill=Model), alpha=0.6) +
    geom_boxplot(width=0.1) +
    annotate(geom="label", x=unique(data$Model), y=rep(letters_pos, 4), label=letters, fontface=2, size=letters_size, label.size=NA, fill=colors) +
    xlab("Model") +
    ylab(paste0(score_label, "\n(100 repetitions)")) +
    ggtitle(score_label) +
    theme_classic() +
    theme(axis.text.x=element_blank())
  return(p)
}

### Plot the distributions of evaluation metrics ###
plot_evaluation_metrics_with_p_values <- function()
{
  data = load_evaluation_metrics()
  ###############################
  my_comparisons = list(c("1) Isotropic", "2) Human activity"), c("1) Isotropic", "3) Road network"), c("1) Isotropic", "4) Combined"), c("2) Human activity", "3) Road network"), c("2) Human activity", "4) Combined"), c("3) Road network", "4) Combined"))
  ###############################
  p1 = plot_score_with_p_values(data, my_comparisons, "AUC", "AUC", 2.5)
  p2 = plot_score_with_p_values(data, my_comparisons, "Sensitivity", "Sensitivity", 2.5)
  p3 = plot_score_with_p_values(data, my_comparisons, "Specificity", "Specificity", 2.5)
  p4 = plot_score_with_p_values(data, my_comparisons, "F1", "F1 score", 2.5)
  p5 = plot_score_with_p_values(data, my_comparisons, "KAPPA", "Standard Kappa", 2.5)
  p6 = plot_score_with_p_values(data, my_comparisons, "TSS", "True skill statistic", 2.5)
  ###############################
  p = ggarrange(p1, p2, p3, p4, p5, p6, ncol=2, nrow=3, common.legend = TRUE, legend="bottom", labels=c("(a)","(b)","(c)","(d)","(e)","(f)"))
  return(p)
}

### Plot the distributions of evaluation metrics ###
plot_evaluation_metrics_with_letters <- function()
{
  data = load_evaluation_metrics()
  ###############################
  my_comparisons = list(c("1) Isotropic", "2) Human activity"), c("1) Isotropic", "3) Road network"), c("1) Isotropic", "4) Combined"), c("2) Human activity", "3) Road network"), c("2) Human activity", "4) Combined"), c("3) Road network", "4) Combined"))
  ###############################
  letters = c("a", "b", "c", "c")
  colors  = c("white", "white", "darkolivegreen1", "darkolivegreen1")
  p1      = plot_score_with_letters(data, my_comparisons, "AUC", "AUC", letters, colors, 0.835)
  ###############################
  letters = c("a", "b", "c", "d")
  colors  = c("white", "white", "white", "darkolivegreen1")
  p2      = plot_score_with_letters(data, my_comparisons, "Sensitivity", "Sensitivity", letters, colors, 1.15)
  ###############################
  letters = c("a", "a", "b", "a")
  colors  = c("white", "white", "darkolivegreen1", "white")
  p3      = plot_score_with_letters(data, my_comparisons, "Specificity", "Specificity", letters, colors, 1.15)
  ###############################
  letters = c("a", "b", "c", "d")
  colors  = c("white", "white", "darkolivegreen1", "white")
  p4      = plot_score_with_letters(data, my_comparisons, "F1", "F1 score", letters, colors, 0.55)
  ###############################
  letters = c("a", "a", "b", "c")
  colors  = c("white", "white", "darkolivegreen1", "white")
  p5      = plot_score_with_letters(data, my_comparisons, "KAPPA", "Standard Kappa", letters, colors, 0.45)
  ###############################
  letters = c("a", "b", "c", "d")
  colors  = c("white", "white", "white", "darkolivegreen1")
  p6      = plot_score_with_letters(data, my_comparisons, "TSS", "True skill statistic", letters, colors, 0.60)
  ###############################
  p = ggarrange(p1, p2, p3, p4, p5, p6, ncol=2, nrow=3, common.legend = TRUE, legend="bottom", labels=c("(a)","(b)","(c)","(d)","(e)","(f)"))
  return(p)
}

##################
#      MAIN      #
##################

args    = commandArgs(trailingOnly = TRUE)
WORKDIR = args[1]
setwd(WORKDIR)

p = plot_evaluation_metrics_with_letters()
ggsave("figures/Figure4.pdf", p, width=7, height=8, units="in")

