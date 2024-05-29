#!/usr/bin/env Rscript
# coding: utf-8

suppressWarnings(library("ggplot2"))
suppressWarnings(library("cowplot"))

### Load log-likelihood and AIC data ###
load_log_likelihood_and_AIC <- function()
{
  #---------------------------------------------------#
  # 1) Load the datasets                              #
  #---------------------------------------------------#
  isotropic_all       = read.table("2_cmaes_validation/1-isotropic_all.txt", sep=" ", h=T)
  human_activity_all  = read.table("2_cmaes_validation/2-human_activity_all.txt", sep=" ", h=T)
  road_network_all    = read.table("2_cmaes_validation/3-road_network_all.txt", sep=" ", h=T)
  combined_all        = read.table("2_cmaes_validation/4-combined_all.txt", sep=" ", h=T)
  isotropic_mean      = read.table("2_cmaes_validation/1-isotropic_mean.txt", sep=" ", h=T)
  human_activity_mean = read.table("2_cmaes_validation/2-human_activity_mean.txt", sep=" ", h=T)
  road_network_mean   = read.table("2_cmaes_validation/3-road_network_mean.txt", sep=" ", h=T)
  combined_mean       = read.table("2_cmaes_validation/4-combined_mean.txt", sep=" ", h=T)
  #---------------------------------------------------#
  # 2) Order mean log-likelihoods by increasing order #
  #---------------------------------------------------#
  isotropic_mean      = isotropic_mean[order(isotropic_mean$replay_mean),]
  human_activity_mean = human_activity_mean[order(human_activity_mean$replay_mean),]
  road_network_mean   = road_network_mean[order(road_network_mean$replay_mean),]
  combined_mean       = combined_mean[order(combined_mean$replay_mean),]
  #---------------------------------------------------#
  # 3) Get replayed log-likelihoods                   #
  #---------------------------------------------------#
  L1 = isotropic_all[isotropic_all$cmaes==isotropic_mean$cmaes[1],"replay"]
  L2 = human_activity_all[human_activity_all$cmaes== human_activity_mean$cmaes[1],"replay"]
  L3 = road_network_all[road_network_all$cmaes== road_network_mean$cmaes[1],"replay"]
  L4 = combined_all[combined_all$cmaes==combined_mean$cmaes[1],"replay"]
  #---------------------------------------------------#
  # 4) Compute AICs : 2*-log(L)+2*K                   #
  #---------------------------------------------------#
  isotropic_nb_params      = 5
  human_activity_nb_params = 5
  road_network_nb_params   = 9
  combined_nb_params       = 9
  AIC1                     = 2*L1+2*isotropic_nb_params
  AIC2                     = 2*L2+2*human_activity_nb_params
  AIC3                     = 2*L3+2*road_network_nb_params
  AIC4                     = 2*L4+2*combined_nb_params
  #---------------------------------------------------#
  # 5) Build the dataset                              #
  #---------------------------------------------------#
  models      = c(rep("1) Isotropic", length(L1)),
                  rep("2) Human activity", length(L2)),
                  rep("3) Road network", length(L3)),
                  rep("4) Combined", length(L4)))
  vector1     = c(L1, L2, L3, L4)
  vector2     = c(AIC1, AIC2, AIC3, AIC4)
  data        = as.data.frame(cbind(vector1,vector2))
  data$Model  = as.factor(models)
  names(data) = c("LogLikelihood", "AIC", "Model")
  return(data)
}

### Plot the log-likelihood distributions ###
plot_loglikelihood_distribution <- function()
{
  data           = load_log_likelihood_and_AIC()
  my_comparisons = list(c("1) Isotropic", "2) Human activity"), c("1) Isotropic", "3) Road network"), c("1) Isotropic", "4) Combined"), c("2) Human activity", "3) Road network"), c("2) Human activity", "4) Combined"), c("3) Road network", "4) Combined"))
  ### LOG-LIKELIHOOD DISTRIBUTIONS ###
  p = ggplot(data, aes(x=Model, y=LogLikelihood)) +
    scale_fill_brewer(palette = "BrBG") +
    geom_violin(aes(fill=Model), alpha=0.6) +
    geom_boxplot(width=0.1) +
    annotate(geom="text", x=unique(data$Model), y=c(172,180,160,170), label=c("a", "b", "c", "d"), fontface=2, size=5) +
    xlab("Model") +
    ylab("Log-likelihood distribution (100 repetitions)") +
    ggtitle("Log-likelihood distribution of each calibrated model") +
    theme_classic() +
    theme(axis.text.x=element_blank())
  return(p)
}


##################
#      MAIN      #
##################

args    = commandArgs(trailingOnly = TRUE)
WORKDIR = args[1]
setwd(WORKDIR)

p = plot_loglikelihood_distribution()
ggsave("figures/FigureS2.pdf", p, width=7, height=5, units="in")



