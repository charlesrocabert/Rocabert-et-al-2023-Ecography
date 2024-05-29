#!/bin/bash
# coding: utf-8

cd 5_models_complete_evaluation

################################################

#-------------------------------------------#
# 1) Evaluate the best isotropic model      #
#-------------------------------------------#
rm -rf 1-isotropic
mkdir 1-isotropic
cp -r ../resources/input_files 1-isotropic/input
echo "> Evaluate the best isotropic model"
cd 1-isotropic
python ../../scripts/complete_evaluation.py -validation ../../2_cmaes_validation/1-isotropic_replayed.txt -input input -model-run ../../build/bin/HMD_model_run -model-score ../../scripts/complete_evaluation.R -model-reps 1000 -score-reps 10 -nb-params 5
cd ..

################################################

#-------------------------------------------#
# 2) Evaluate the best human activity model #
#-------------------------------------------#
rm -rf 2-human_activity
mkdir 2-human_activity
cp -r ../resources/input_files 2-human_activity/input
echo "> Evaluate the best human activity model"
cd 2-human_activity
python ../../scripts/complete_evaluation.py -validation ../../2_cmaes_validation/2-human_activity_replayed.txt -input input -model-run ../../build/bin/HMD_model_run -model-score ../../scripts/complete_evaluation.R -model-reps 1000 -score-reps 10 -nb-params 5
cd ..

################################################

#-----------------------------------------#
# 3) Evaluate the best road network model #
#-----------------------------------------#
rm -rf 3-road_network
mkdir 3-road_network
cp -r ../resources/input_files 3-road_network/input
echo "> Evaluate the best road network model"
cd 3-road_network
python ../../scripts/complete_evaluation.py -validation ../../2_cmaes_validation/3-road_network_replayed.txt -input input -model-run ../../build/bin/HMD_model_run -model-score ../../scripts/complete_evaluation.R -model-reps 1000 -score-reps 10 -nb-params 9
cd ..

################################################

#-------------------------------------------#
# 4) Evaluate the best combined model       #
#-------------------------------------------#
rm -rf 4-combined
mkdir 4-combined
cp -r ../resources/input_files 4-combined/input
echo "> Evaluate the best combined model"
cd 4-combined
python ../../scripts/complete_evaluation.py -validation ../../2_cmaes_validation/4-combined_replayed.txt -input input -model-run ../../build/bin/HMD_model_run -model-score ../../scripts/complete_evaluation.R -model-reps 1000 -score-reps 10 -nb-params 9
cd ..

################################################

cd ..
