#!/bin/bash
# coding: utf-8

cd 3_best_models

################################################

#--------------------------------------#
# 1) Run the best isotropic model      #
#--------------------------------------#
rm -rf 1-isotropic
mkdir 1-isotropic
cp -r ../resources/input_files 1-isotropic/input
echo "> Run the best isotropic model (N=1000)"
cd 1-isotropic
python ../../scripts/best_model.py -validation ../../2_cmaes_validation/1-isotropic_replayed.txt -input input -model-run ../../build/bin/HMD_model_run -model-reps 1000
rm output/observed_euclidean_distribution.txt
rm output/simulated_euclidean_distribution.txt
cd ..

#--------------------------------------#
# 2) Run the best human activity model #
#--------------------------------------#
rm -rf 2-human_activity
mkdir 2-human_activity
cp -r ../resources/input_files 2-human_activity/input
echo "> Run the best human activity model (N=1000)"
cd 2-human_activity
python ../../scripts/best_model.py -validation ../../2_cmaes_validation/2-human_activity_replayed.txt -input input -model-run ../../build/bin/HMD_model_run -model-reps 1000
rm output/observed_euclidean_distribution.txt
rm output/simulated_euclidean_distribution.txt
cd ..

#--------------------------------------#
# 3) Run the best road network model   #
#--------------------------------------#
rm -rf 3-road_network
mkdir 3-road_network
cp -r ../resources/input_files 3-road_network/input
echo "> Run the best road network model (N=1000)"
cd 3-road_network
python ../../scripts/best_model.py -validation ../../2_cmaes_validation/3-road_network_replayed.txt -input input -model-run ../../build/bin/HMD_model_run -model-reps 1000
rm output/observed_euclidean_distribution.txt
rm output/simulated_euclidean_distribution.txt
cd ..

#--------------------------------------#
# 4) Run the best combined model       #
#--------------------------------------#
rm -rf 4-combined
mkdir 4-combined
cp -r ../resources/input_files 4-combined/input
echo "> Run the best combined model (N=1000)"
cd 4-combined
python ../../scripts/best_model.py -validation ../../2_cmaes_validation/4-combined_replayed.txt -input input -model-run ../../build/bin/HMD_model_run -model-reps 1000
rm output/observed_euclidean_distribution.txt
rm output/simulated_euclidean_distribution.txt
cd ..

################################################

cd ..
