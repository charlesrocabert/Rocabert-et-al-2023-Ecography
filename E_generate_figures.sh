#!/bin/bash
# coding: utf-8

Rscript scripts/Print_LogLikelihood_AIC_metrics.R $(pwd)
Rscript scripts/Print_Evaluation_metrics.R $(pwd)

Rscript scripts/Figure3.R $(pwd)
Rscript scripts/Figure4.R $(pwd)
Rscript scripts/Figure5.R $(pwd)

Rscript scripts/FigureS2.R $(pwd)

Rscript scripts/Figures_SupportingInformation3.R $(pwd)
Rscript scripts/Figure1_SupportingInformation4.R $(pwd)
Rscript scripts/Figure3_SupportingInformation4.R $(pwd)
Rscript scripts/Figure4_SupportingInformation4.R $(pwd)

Rscript scripts/AnimationS1.R $(pwd)
cd gif
convert -quality 10% -delay 100 -loop 0 *.png AnimationS1.gif
cd ..

