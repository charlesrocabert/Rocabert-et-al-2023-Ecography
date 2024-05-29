#!/usr/bin/env Rscript
# coding: utf-8

suppressWarnings(library("ggplot2"))
suppressWarnings(library("ggpubr"))
suppressWarnings(library("sf"))

### Compute evaluation metrics ###
compute_evaluation_metrics <- function( filename, resolution )
{
  d     = read.table(filename, sep=" ", h=T)
  TH    = seq(0, 1, by=0.001)
  TP    = c()
  FP    = c()
  TN    = c()
  FN    = c()
  SE    = c()
  SP    = c()
  PREC  = c()
  TSS   = c()
  KAPPA = c()
  QDIS  = c()
  ADIS  = c()
  for(th in TH)
  {
    ### Compute positives and negatives ###
    dtp   = d[d$p_obs>0&d$n_obs>0&d$p_sim>=th,]
    dfp   = d[d$p_obs==0&d$n_obs>0&d$p_sim>=th,]
    dtn   = d[d$p_obs==0&d$n_obs>0&d$p_sim<th,]
    dfn   = d[d$p_obs>0&d$n_obs>0&d$p_sim<th,]
    tp    = length(dtp[,1])
    fp    = length(dfp[,1])
    tn    = length(dtn[,1])
    fn    = length(dfn[,1])
    N     = tp+fp+tn+fn
    ### Compute various metrics ###
    tss   = (tp*tn-fp*fn)/((tp+fn)*(fp+tn))
    kappa = (((tp+tn)/N)-((tp+fp)*(tp+fn)+(fn+tn)*(tn+fp))/N^2)/(1-((tp+fp)*(tp+fn)+(fn+tn)*(tn+fp))/N^2)
    TP    = c(TP, tp)
    FP    = c(FP, fp)
    TN    = c(TN, tn)
    FN    = c(FN, fn)
    SE    = c(SE, tp/(tp+fn))
    SP    = c(SP, tn/(fp+tn))
    PREC  = c(PREC, tp/(tp+fp))
    TSS   = c(TSS, tss)
    ### Compute Kappa metrics ###
    N1 = tp+fp
    N2 = fn+tn
    p11 = tp/(tp+fp)*N1/N
    p10 = fp/(tp+fp)*N1/N
    p01 = fn/(fn+tn)*N2/N
    p00 = tn/(fn+tn)*N2/N
    s1j = p11+p10 # First line
    s0j = p01+p00 # Second line
    sj1 = p11+p01 # First column
    sj0 = p10+p00 # Second column
    # -> quantity disagreement
    q1 = abs(sj1-s1j)
    q0 = abs(sj0-s0j)
    Q  = (q1+q0)/2
    # -> allocation disagreement
    a1 = 2*min(c(sj1-p11, s1j-p11))
    a0 = 2*min(c(sj0-p00, s0j-p00))
    A  = (a1+a0)/2
    # -> standard Kappa
    C  = p11+p00
    e1 = sj1*s1j
    e0 = sj0*s0j
    E  = e1+e0
    kappa = (C-E)/(1-E)
    # -> save values
    QDIS  = c(QDIS, Q)
    ADIS  = c(ADIS, A)
    KAPPA = c(KAPPA, kappa)
  }
  metrics        = cbind(TH, TP, FP, TN, FN, SE, 1-SP, PREC, TSS, QDIS, ADIS, KAPPA)
  metrics        = as.data.frame(metrics)
  metrics$d      = sqrt((metrics[,6])^2+(1-metrics[,7])^2)
  CSI            = metrics$TP/(metrics$TP+metrics$FN+metrics$FP)
  ACC            = (metrics$TP+metrics$TN)/(metrics$TP+metrics$TN+metrics$FN+metrics$FP)
  F1             = 2*metrics$TP/(2*metrics$TP+metrics$FN+metrics$FP)
  MCC            = ((metrics$TP*metrics$TN)-(metrics$FP*metrics$FN))/(sqrt((metrics$TP+metrics$FP)*(metrics$TP+metrics$FN)*(metrics$TN+metrics$FP)*(metrics$TN+metrics$FN)))
  metrics$CSI    = CSI
  metrics$ACC    = ACC
  metrics$F1     = F1
  metrics$MCC    = MCC
  names(metrics) = c("TH", "TP", "FP", "TN", "FN", "TPR", "FPR", "PREC", "TSS", "QDIS", "ADIS", "KAPPA", "d", "CSI", "ACC", "F1", "MCC")
  return(metrics)
}

### Compute evaluation metrics ###
compute_AUC <- function( metrics )
{
  metrics = metrics[order(metrics$FPR),]
  AUC     = 0.0
  for (i in 2:dim(metrics)[1])
  {
    step = metrics$FPR[i]-metrics$FPR[(i-1)]
    area = (metrics$TPR[(i-1)]+metrics$TPR[i])/2
    AUC  = AUC + step*area
  }
  return(AUC)
}

### Get maximum index value with asociated threshold value ###
get_maximum <- function( metrics, index_name, index_list )
{
  best_line = metrics[order(metrics[,index_name], decreasing=T),][1,]
  res = unlist(best_line[index_list])
  return(res)
}

### Extract the best metrics ###
build_best_metrics <- function( metrics )
{
  AUC    = compute_AUC(metrics)
  result = c(
    AUC,
    get_maximum(metrics, "d", c("TH", "d", "TPR", "FPR")),
    get_maximum(metrics, "ACC", c("TH", "ACC")),
    get_maximum(metrics, "F1", c("TH", "F1")),
    get_maximum(metrics, "KAPPA", c("TH", "KAPPA", "QDIS", "ADIS")),
    get_maximum(metrics, "TSS", c("TH", "TSS"))
  )
  result           = as.data.frame(result)
  rownames(result) = c("AUC", "d_th", "d", "TPR", "FPR", "ACC_th", "ACC", "F1_th", "F1", "KAPPA_th", "KAPPA", "QDIS", "ADIS", "TSS_th", "TSS")
  return(result)
}

### Plot best scenarios invasion patterns ###
plot_invasion_map <- function( sim_filename, threshold_name, threshold_label, threshold_resolution, title, xintro, yintro )
{
  #--------------------------#
  # 1) Load and prepare data #
  #--------------------------#
  urban       = st_read("resources/input_files/UMZ2006_cut2.shx")
  coordCorrec = c(st_bbox(urban)[1]+1, st_bbox(urban)[2]+1)
  data        = read.table(sim_filename, h=T)
  metrics     = compute_evaluation_metrics(sim_filename, threshold_resolution)
  result      = build_best_metrics(metrics)
	threshold   = result[threshold_name,1][[1]]
	data_yobs   = data[data$y_obs>0.0,]
	data_nobs   = data[data$y_obs==0.0&data$n_obs>0.0,]
	data_sim    = data[data$p_sim>threshold,]
	pres        = length(data[data$y_obs>0.0&data$p_sim>threshold,1])/length(data[data$y_obs>0.0,1])
	abse        = length(data[data$y_obs==0.0&data$p_sim<=threshold,1])/length(data[data$y_obs==0.0,1])
	sentence    = paste(round(pres,2)*100, "% predicted negatives\n", round(abse,2)*100, "% predicted positives", sep="")
	#--------------------------#
	# 2) Create figure         #
	#--------------------------#
	p = ggplot() +
	  geom_sf(data=st_geometry(urban), color=NA, fill="grey") +
	  geom_point(data=data_sim, aes(x=x+coordCorrec[1], y=y+coordCorrec[2], color="Predicted invasions", shape="Predicted invasions", size="Predicted invasions")) +
	  geom_point(data=data_nobs, aes(x=x+coordCorrec[1], y=y+coordCorrec[2], color="Not invaded cells", shape="Not invaded cells", size="Not invaded cells")) +
	  geom_point(data=data_yobs, aes(x=x+coordCorrec[1], y=y+coordCorrec[2], color="Invaded cells", shape="Invaded cells", size="Invaded cells")) +
		geom_point(aes(x=xintro+coordCorrec[1], y=yintro+coordCorrec[2], color="Introduction site", shape="Introduction site", size="Introduction site"), stroke=1) +
  	#annotate(geom="label", x=0+coordCorrec[1], y=130000+coordCorrec[2], label=sentence, fill="white", hjust=0) +
	  labs(fill="Simulated\nprobability\nof presence") +
  	xlab("Longitude") +
  	ylab("Latitude") +
  	ggtitle(paste0(title,"\n(",threshold_label,")")) +
  	theme_classic() +
	  labs(color="", shape="", size="") +
	  scale_color_manual(values=c("red", "#E69F00", "#56B4E9", "#111111")) +
	  scale_shape_manual(values=c(3, 1, 1, 16)) +
	  scale_size_manual(values=c(3, 0.8, 0.8, 0.6)) +
	  theme(legend.position = c(0.95, 0.25))
	return(p)
}


##################
#      MAIN      #
##################

args    = commandArgs(trailingOnly = TRUE)
WORKDIR = args[1]
setwd(WORKDIR)

threshold_resolution = 0.001
threshold_names      = c("d_th", "F1_th", "KAPPA_th", "TSS_th")
threshold_labels     = c("Standard ROC threshold", "Maximum F1 score", "Maximum standard Kappa", "Maximum true skill statistic")
figure_names        = c("Figure1_SupportingInformation3", "Figure2_SupportingInformation3", "Figure3_SupportingInformation3", "Figure4_SupportingInformation3")
for(i in 1:length(threshold_names))
{
  threshold_name  = threshold_names[i]
  threshold_label = threshold_labels[i]
  figure_name     = figure_names[i]
  print(paste0(">>> ", threshold_name, "(", threshold_label, ")"))
  p1 = plot_invasion_map("3_best_models/1-isotropic/output/final_state.txt",
                         threshold_name, threshold_label, threshold_resolution,
                         "Isotropic model", 20026.56, 73514.26)
  p2 = plot_invasion_map("3_best_models/2-human_activity/output/final_state.txt",
                         threshold_name, threshold_label, threshold_resolution,
                         "Human activity model", 29673.02, 58030.17)
  p3 = plot_invasion_map("3_best_models/3-road_network/output/final_state.txt",
                         threshold_name, threshold_label, threshold_resolution,
                         "Road network model", 31238.47, 66451.83)
  p4 = plot_invasion_map("3_best_models/4-combined/output/final_state.txt",
                         threshold_name, threshold_label, threshold_resolution,
                         "Combined model", 59220.72, 34054.31)
  p  = ggarrange(p1, p2, p3, p4, ncol=2, nrow=2, common.legend = TRUE, legend="right", labels=c("(a)","(b)","(c)","(d)"))
  ggsave(paste0("figures/",figure_name,".pdf"), p, width=9, height=7.6, units="in")
}

