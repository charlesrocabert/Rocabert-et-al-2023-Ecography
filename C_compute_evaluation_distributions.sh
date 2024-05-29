#!/bin/bash
# coding: utf-8

cd 4_models_evaluation

################################################

#-------------------------------------------#
# 1) Evaluate the best isotropic model      #
#-------------------------------------------#
rm -rf 1-isotropic
mkdir 1-isotropic
cp -r ../resources/input_files 1-isotropic/input
echo "> Evaluate the best isotropic model"
cd 1-isotropic
python ../../scripts/evaluate.py -validation ../../2_cmaes_validation/1-isotropic_replayed.txt -input input -model-run ../../build/bin/HMD_model_run -model-eval ../../scripts/evaluation.R -model-reps 1000 -eval-reps 100
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
python ../../scripts/evaluate.py -validation ../../2_cmaes_validation/2-human_activity_replayed.txt -input input -model-run ../../build/bin/HMD_model_run -model-eval ../../scripts/evaluation.R -model-reps 1000 -eval-reps 100
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
python ../../scripts/evaluate.py -validation ../../2_cmaes_validation/3-road_network_replayed.txt -input input -model-run ../../build/bin/HMD_model_run -model-eval ../../scripts/evaluation.R -model-reps 1000 -eval-reps 100
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
python ../../scripts/evaluate.py -validation ../../2_cmaes_validation/4-combined_replayed.txt -input input -model-run ../../build/bin/HMD_model_run -model-eval ../../scripts/evaluation.R -model-reps 1000 -eval-reps 100
cd ..

################################################

cd ..
