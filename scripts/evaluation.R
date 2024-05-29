#!/usr/bin/env Rscript
# coding: utf-8

### Compute Boyce index (DEPRECATED) ###
compute_boyce_index <- function()
{
  d       = read.table("./output/final_state.txt", sep=" ", h=T)
  TH      = seq(0,1,by=0.001)
  P_total = length(d[d$p_obs>0,1])
  N       = length(d[d$n_obs>0,1])
  RES     = c()
  for(th in TH)
  {
    dl     = d[d$n_obs>0&d$p_sim>th,]
    P_i    = length(dl[dl$p_obs>0,1])
    Pred_i = length(dl[,1])
    O      = P_i/P_total
    E      = Pred_i/N
    RES    = rbind(RES, c(th, O, E, O/E))
  }
  RES = as.data.frame(RES)
  names(RES) = c("THi", "Oi", "Ei", "Fi")
  RES = RES[!is.na(RES$Fi),]
  test     = cor.test(RES$THi, RES$Fi, method="spearman")
  estimate = test$estimate[[1]]
  pvalue   = test$p.value[[1]]
  result        = as.data.frame(cbind(estimate,pvalue))
  names(result) = c("BOYCE_index","BOYCE_pvalue")
  return(result)
}

### Compute evaluation metrics ###
compute_evaluation_metrics <- function( resolution )
{
	d     = read.table("./output/final_state.txt", sep=" ", h=T)
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

### Plot Receiver operator curve (ROC) ###
plot_ROC <- function( metrics, title )
{
  p = ggplot(metrics, aes(FPR, TPR)) +
    geom_line() +
    theme_minimal() +
    xlab("False positive rate") +
    ylab("True positive rate") +
    ggtitle(title)
  return(p)
}

### Plot metrics ###
plot_metrics <- function( metrics )
{
  p1 = ggplot(metrics, aes(TH, TPR)) + geom_line() + xlab("Threshold") + ylab("") + ggtitle("Sensitivity")
  p2 = ggplot(metrics, aes(TH, 1-FPR)) + geom_line() + xlab("Threshold") + ylab("") + ggtitle("Specificity")
  p3 = ggplot(metrics, aes(TH, ACC)) + geom_line() + xlab("Threshold") + ylab("") + ggtitle("Accuracy")
  p4 = ggplot(metrics, aes(TH, F1)) + geom_line() + xlab("Threshold") + ylab("") + ggtitle("F1")
  p5 = ggplot(metrics, aes(TH, KAPPA)) + geom_line() + xlab("Threshold") + ylab("") + ggtitle("Standard Kappa")
  p6 = ggplot(metrics, aes(TH, QDIS)) + geom_line() + xlab("Threshold") + ylab("") + ggtitle("Quantity disagreement")
  p7 = ggplot(metrics, aes(TH, ADIS)) + geom_line() + xlab("Threshold") + ylab("") + ggtitle("Allocation disagreement")
  p8 = ggplot(metrics, aes(TH, TSS)) + geom_line() + xlab("Threshold") + ylab("") + ggtitle("True skill statistic")
  p = plot_grid(p1, p2, p3, p4, p5, p6, p7, p8, ncol=2)
  return(p)
}


##################
#      MAIN      #
##################

args    = commandArgs(trailingOnly = TRUE)
WORKDIR = args[1]
setwd(WORKDIR)

metrics = compute_evaluation_metrics(0.001)
result  = build_best_metrics(metrics)

# plot_metrics(metrics)
# plot_ROC(metrics, "3) Road network model") + geom_point(aes(x=RESULT[5,1], y=RESULT[4,1]), colour="red")

print(result)

