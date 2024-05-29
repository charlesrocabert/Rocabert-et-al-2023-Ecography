#!/bin/bash
# coding: utf-8

cd 2_cmaes_validation

################################################

#--------------------------------------#
# 1) Validate the isotropic model      #
#--------------------------------------#
echo "> Validate the isotropic models"
python ../scripts/validate.py -models ../1_simulation_results/1-isotropic_best.txt -input ../resources/input_files -model-run ../build/bin/HMD_model_run -model-reps 1000 -validation-reps 100 -validation-range 100
mv estimations_all.txt 1-isotropic_all.txt
mv estimations_mean.txt 1-isotropic_mean.txt
mv rebuilt_list_of_parameter_sets.txt 1-isotropic_replayed.txt

#--------------------------------------#
# 2) Validate the human activity model #
#--------------------------------------#
echo "> Validate the human activity models"
python ../scripts/validate.py -models ../1_simulation_results/2-human_activity_best.txt -input ../resources/input_files -model-run ../build/bin/HMD_model_run -model-reps 1000 -validation-reps 100 -validation-range 100
mv estimations_all.txt 2-human_activity_all.txt
mv estimations_mean.txt 2-human_activity_mean.txt
mv rebuilt_list_of_parameter_sets.txt 2-human_activity_replayed.txt

#--------------------------------------#
# 3) Validate the road network model   #
#--------------------------------------#
echo "> Validate the road network models"
python ../scripts/validate.py -models ../1_simulation_results/3-road_network_best.txt -input ../resources/input_files -model-run ../build/bin/HMD_model_run -model-reps 1000 -validation-reps 100 -validation-range 100
mv estimations_all.txt 3-road_network_all.txt
mv estimations_mean.txt 3-road_network_mean.txt
mv rebuilt_list_of_parameter_sets.txt 3-road_network_replayed.txt

#--------------------------------------#
# 4) Validate the combined model       #
#--------------------------------------#
echo "> Validate the combined models"
python ../scripts/validate.py -models ../1_simulation_results/4-combined_best.txt -input ../resources/input_files -model-run ../build/bin/HMD_model_run -model-reps 1000 -validation-reps 100 -validation-range 100
mv estimations_all.txt 4-combined_all.txt
mv estimations_mean.txt 4-combined_mean.txt
mv rebuilt_list_of_parameter_sets.txt 4-combined_replayed.txt

################################################

cd ..
