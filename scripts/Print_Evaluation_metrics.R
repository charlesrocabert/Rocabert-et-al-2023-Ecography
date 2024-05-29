#!/usr/bin/env Rscript
# coding: utf-8

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

### Print metrics ###
print_metrics <- function()
{
  data = load_evaluation_metrics()
  for (metric in c("AUC", "Sensitivity", "Specificity", "ACC", "F1", "KAPPA", "QDIS", "ADIS", "TSS"))
  {
    print(paste(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>",metric))
    for (model in unique(data$Model))
    {
      N  = length(data[data$Model==model,metric])
      m  = mean(data[data$Model==model,metric])
      se = sd(data[data$Model==model,metric])/sqrt(N)
      print(paste(model, round(m,3), formatC(se, format = "e", digits = 2)))
    }
  }
}


##################
#      MAIN      #
##################

args    = commandArgs(trailingOnly = TRUE)
WORKDIR = args[1]
setwd(WORKDIR)

print_metrics()

