#!/usr/bin/env Rscript
# coding: utf-8

suppressWarnings(library("tidyverse"))
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

### Load HMD event counts ###
load_HMD_events_count <- function()
{
  #----------------------#
  # 1) Load the datasets #
  #----------------------#
  d1 = read.table("3_best_models/1-isotropic/output/lineage_tree.txt", h=T, sep=" ")
  d2 = read.table("3_best_models/2-human_activity/output/lineage_tree.txt", h=T, sep=" ")
  d3 = read.table("3_best_models/3-road_network/output/lineage_tree.txt", h=T, sep=" ")
  d4 = read.table("3_best_models/4-combined/output/lineage_tree.txt", h=T, sep=" ")
  t1 = as.data.frame(table(d1[,c("repetition", "iteration")]))
  t2 = as.data.frame(table(d2[,c("repetition", "iteration")]))
  t3 = as.data.frame(table(d3[,c("repetition", "iteration")]))
  t4 = as.data.frame(table(d4[,c("repetition", "iteration")]))
  names(t1)  = c("Repetition", "Timestep", "Count")
  names(t2)  = c("Repetition", "Timestep", "Count")
  names(t3)  = c("Repetition", "Timestep", "Count")
  names(t4)  = c("Repetition", "Timestep", "Count")
  #----------------------#
  # 2) Build the dataset #
  #----------------------#
  models     = c(rep("1) Isotropic", dim(t1)[1]),
                rep("2) Human activity", dim(t2)[1]),
                rep("3) Road network", dim(t3)[1]),
                rep("4) Combined", dim(t4)[1]))
  data       = as.data.frame(rbind(t1, t2, t3, t4))
  data$Model = as.factor(models)
  return(data)
}

### Build the dataset ###
build_dataset <- function()
{
  d1 = load_log_likelihood_and_AIC()
  d2 = load_HMD_events_count()
  #############################
  x1_mean = mean((filter(d1, Model=="1) Isotropic")$LogLikelihood))
  x1_sd   = sd((filter(d1, Model=="1) Isotropic")$LogLikelihood))
  x2_mean = mean((filter(d1, Model=="2) Human activity")$LogLikelihood))
  x2_sd   = sd((filter(d1, Model=="2) Human activity")$LogLikelihood))
  x3_mean = mean((filter(d1, Model=="3) Road network")$LogLikelihood))
  x3_sd   = sd((filter(d1, Model=="3) Road network")$LogLikelihood))
  x4_mean = mean((filter(d1, Model=="4) Combined")$LogLikelihood))
  x4_sd   = sd((filter(d1, Model=="4) Combined")$LogLikelihood))
  #############################
  y1_mean = mean(filter(d2, Timestep==24 & Model=="1) Isotropic")$Count)
  y1_sd   = sd(filter(d2, Timestep==24 & Model=="1) Isotropic")$Count)
  y2_mean = mean(filter(d2, Timestep==24 & Model=="2) Human activity")$Count)
  y2_sd   = sd(filter(d2, Timestep==24 & Model=="2) Human activity")$Count)
  y3_mean = mean(filter(d2, Timestep==24 & Model=="3) Road network")$Count)
  y3_sd   = sd(filter(d2, Timestep==24 & Model=="3) Road network")$Count)
  y4_mean = mean(filter(d2, Timestep==24 & Model=="4) Combined")$Count)
  y4_sd   = sd(filter(d2, Timestep==24 & Model=="4) Combined")$Count)
  #############################
  LogLikelihood    = c(x1_mean, x2_mean, x3_mean, x4_mean)
  LogLikelihood_sd = c(x1_sd, x2_sd, x3_sd, x4_sd)
  Count            = c(y1_mean, y2_mean, y3_mean, y4_mean)
  Count_sd         = c(y1_sd, y2_sd, y3_sd, y4_sd)
  Model            = c("1) Isotropic", "2) Human activity", "3) Road network", "4) Combined")
  #############################
  D = data.frame(LogLikelihood, LogLikelihood_sd, Count, Count_sd, Model)
  return(D)
}

### Plot HMD event counts VS. likelihood correlations ###
plot_HMD_likelihood_correlation <- function( D )
{
  cort      = cor.test(D$LogLikelihood, D$Count)
  cor_pval  = formatC(cort$p.value, format="e", digits=2)
  cor_rho   = round(cort$estimate[[1]],2)
  stat_line = paste("Pearson = ", cor_rho, "\n(p-value = ", cor_pval, ")", sep="")
  p = ggplot(D, aes(x=LogLikelihood, y=Count)) +
    geom_point() +
    geom_smooth(color="#3497a9", fill="#3497a9", span=0.9, method="lm") +
    #geom_smooth(span=0.9, method="lm") +
    #geom_errorbar(aes(xmin=LogLikelihood-LogLikelihood_sd, xmax=LogLikelihood+LogLikelihood_sd), width=.2) +
    #geom_errorbar(aes(ymin=Count-Count_sd, ymax=Count+Count_sd), width=.2) +
    xlab("Mean log-likelihood") +
    ylab("Mean number of dispersal events") +
    ggtitle("Model's log-likelihood correlates\nwith the number of simulated HMD events") +
    annotate(geom="text", x=165, y=10, label=stat_line, hjust=0) +
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
# 1) Build the figure #
#---------------------#
D = build_dataset()
p = plot_HMD_likelihood_correlation(D)
ggsave("figures/Figure5_SupportingInformation4.pdf", p, width=5, height=5, units="in")


