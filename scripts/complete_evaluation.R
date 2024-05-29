#!/usr/bin/env Rscript
# coding: utf-8

#options(show.error.messages=FALSE, warn=-1)
args         = commandArgs(trailingOnly = TRUE)
WORKDIR      = args[1]
TIMESTEP_MAX = as.numeric(args[2])
NB_PARAMS    = as.numeric(args[3])

setwd(WORKDIR)

### Compute fitting scores ###
compute_fitting_scores <- function( d, nb_params )
{
  #---------------------------------#
  # 1) Compute fitting scores       #
  #---------------------------------#
  N           = length(d[,1])
  L           = dhyper(d[d$n_obs>0,"y_sim"], d[d$n_obs>0,"n_sim"], d[d$n_obs>0,"n_obs"], d[d$n_obs>0,"y_obs"]+d[d$n_obs>0,"y_sim"])
  logL        = sum(-log(L))
  AIC         = 2*logL+2*nb_params
  nb_colonies = sum(d[d$n_obs>0,"p_sim"]*d[d$n_obs>0,"n_obs"])
  #---------------------------------#
  # 2) Build and return the dataset #
  #---------------------------------#
  result        = as.data.frame(cbind(logL, AIC, nb_colonies))
  names(result) = c("LogL", "AIC", "nb_colonies")
  return(result)
}

### Compute AUC score ###
compute_AUC <- function( d )
{
  #--------------------------------------------#
  # 1) Compute ROC and find the best threshold #
  #--------------------------------------------#
  TH    = seq(0, 1, by=0.001)
  TP    = c()
  FP    = c()
  TN    = c()
  FN    = c()
  TSS   = c()
  KAPPA = c()
  SE    = c()
  SP    = c()
  PREC  = c()
  for(th in TH)
  {
    dtp   = d[d$p_obs>0&d$n_obs>0&d$p_sim>=th,]
    dfp   = d[d$p_obs==0&d$n_obs>0&d$p_sim>=th,]
    dtn   = d[d$p_obs==0&d$n_obs>0&d$p_sim<th,]
    dfn   = d[d$p_obs>0&d$n_obs>0&d$p_sim<th,]
    tp    = length(dtp[,1])
    fp    = length(dfp[,1])
    tn    = length(dtn[,1])
    fn    = length(dfn[,1])
    N     = tp+fp+tn+fn
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
    KAPPA = c(KAPPA, kappa)
  }
  ROC        = cbind(TH, TP, FP, TN, FN, SE, 1-SP, PREC, TSS, KAPPA)
  ROC        = as.data.frame(ROC)
  ROC$d      = sqrt(ROC[,7]^2+(1-ROC[,6])^2)
  CSI        = ROC$TP/(ROC$TP+ROC$FN+ROC$FP)
  ACC        = (ROC$TP+ROC$TN)/(ROC$TP+ROC$TN+ROC$FN+ROC$FP)
  F1         = 2*ROC$TP/(2*ROC$TP+ROC$FN+ROC$FP)
  MCC        = ((ROC$TP*ROC$TN)-(ROC$FP*ROC$FN))/(sqrt((ROC$TP+ROC$FP)*(ROC$TP+ROC$FN)*(ROC$TN+ROC$FP)*(ROC$TN+ROC$FN)))
  ROC$CSI    = CSI
  ROC$ACC    = ACC
  ROC$F1     = F1
  ROC$MCC    = MCC
  names(ROC) = c("TH", "TP", "FP", "TN", "FN", "TPR", "FPR", "PREC", "TSS", "KAPPA", "d", "CSI", "ACC", "F1", "MCC")
  ROC        = ROC[order(ROC$d),]
  best_line  = ROC[1,]

  #--------------------------------------------#
  # 2) Compute AUC                             #
  #--------------------------------------------#
  ROC = ROC[order(ROC$FPR),]
  AUC = 0.0
  for (i in seq(2,length(ROC[,1])))
  {
    step = ROC$FPR[i]-ROC$FPR[(i-1)]
    area = (ROC$TPR[(i-1)]+ROC$TPR[i])/2
    AUC  = AUC + step*area
  }

  #--------------------------------------------#
  # 3) Build and return the dataset            #
  #--------------------------------------------#
  result        = as.data.frame(AUC)
  names(result) = c("AUC")
  return(result)
}

### Compute Boyce index ###
compute_boyce_index <- function( d )
{
  #----------------------------------------#
  # 1) Compute Boyce measures by threshold #
  #----------------------------------------#
  TH      = seq(0,1,by=0.001)
  P_total = length(d[d$p_obs>0,1])
  N       = length(d[d$n_obs>0,1])
  RES     = c()
  for(th in TH)
  {
    dl     = d[d$n_obs>0&d$p_sim>th,]
    P_i    = length(dl[dl$p_obs>0,1])
    Pred_i = length(dl[,1])
    O      = 0.0
    if (P_total > 0.0)
    {
      O = P_i/P_total
    }
    E = 0.0
    if (N > 0.0)
    {
      E = Pred_i/N
    }
    RES = rbind(RES, c(th, O, E, O/E))
  }
  RES = as.data.frame(RES)
  names(RES) = c("THi", "Oi", "Ei", "Fi")
  RES = RES[!is.na(RES$Fi),]

  #--------------------------------------------#
  # 2) Compute the Boyce index                 #
  #--------------------------------------------#
  estimate = NA
  pvalue   = NA
  if (length(RES[,1]) > 1)
  {
    test     = cor.test(RES$THi, RES$Fi, method="spearman")
    estimate = test$estimate[[1]]
    pvalue   = test$p.value[[1]]
  }

  #--------------------------------------------#
  # 3) Build and return the dataset            #
  #--------------------------------------------#
  result        = as.data.frame(cbind(estimate,pvalue))
  names(result) = c("BOYCE_index","BOYCE_pvalue")
  return(result)
}


##################
#      MAIN      #
##################

result = c()
for(timestep in seq(1,TIMESTEP_MAX))
{
  print(timestep)
  ######################
  filename = paste("./output/state_", timestep,".txt", sep="")
  if (timestep==TIMESTEP_MAX)
  {
    filename = "./output/final_state.txt"
  }
  data = read.table(filename, sep=" ", h=T)
  ######################
  result1 = compute_fitting_scores(data, NB_PARAMS)
  result2 = compute_AUC(data)
  result3 = compute_boyce_index(data)
  result  = rbind(result, cbind(timestep, result1, result2, result3))

}
result = as.data.frame(result)
names(result) = c("t", "logL", "AIC", "nb_colonies", "AUC", "BOYCE_index","BOYCE_pvalue")

write.table(result, file="complete_evaluation.txt", row.names=F, col.names=T, quote=F, sep=" ")
