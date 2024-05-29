<p align="center">
<strong>Supporting information for Rocabert et al. (2023) publication: <em>"Accounting for the topology of road networks to better explain human-mediated dispersal in terrestrial landscapes"</em></strong>
<br />
</p>

-----------------

<strong>Note to the reader: this package has been anonymized for the purpose of the review process.</strong> 

## 1. Introduction

Once the repository has been dowloaded, you can run the pipeline to produce post-analyses from simulation results (available in the folder <code>1_simulation_results</code>).

The six bash scripts necessary to fully reproduce the analysis are labeled from A to F, and must be executed in this order. The post-analyses files are already available in this package. Be aware that re-running the full pipeline will erase the files and will take several hours. You can skip the first steps and jump directly to the section 6: generating the figures of the manuscript.

Before taking the next steps, navigate to the repository using the command <code>cd</code> in your terminal.

You can access the main publication here: https://doi.org/10.1111/ecog.07068

## 2. Supported platforms and dependencies

The software has been successfully tested on Unix/Linux and macOS platforms.

#### Dependencies 
- A C++ compiler (GCC, LLVM, ...), 
- CMake (command line version), 
- GSL for C/C++, 
- CBLAS for C/C++, 
- Python ≥ 3 (Packages CMA-ES and numpy are required), 
- R (packages ggplot2, cowplot, ggpubr and sf are required).

## 3. Compile the simulation executable

To compile the executable, navigate to the folder cmake, and run the following command line in a terminal:

```
bash make_release.sh
```

## 4. Run the validation of the CMA-ES outputs

To compute the log-likelihood distribution of the parameters sets found by the optimization algorithm (100 repetitions, see Main Document), run the following command line in a terminal:

```
bash A_run_validation.sh
```

Resulting files will be saved in the folder <code>2_cmaes_validation</code>. This script will take several hours.

## 5. Find and run the best parameters set of each scenario

The next script finds the best parameters set of each model by comparing the average log-likelihoods and selecting the lowest one (see Main Document). The script then run a simulation with <code>N=1,000</code> repetitions. Run the following command line in a terminal:

```
bash B_run_best_models.sh
```

Resulting files will be saved in the folder <code>3_best_models</code>.

## 6. Compute performance metrics distributions

To compute the various performance metrics associated to each calibrated model (see Main Document), run the following scripts:

```
bash C_compute_evaluation_distributions.sh
```

And:

```
bash D_compute_complete_evaluation_distributions.sh
```

This operation could also take some time. Resulting files will be saved in the folders <code>4_models_evaluation</code> and <code>5_models_complete_evaluation</code>.

## 7. Generate the figures of the manuscript

To generate the figures of this manuscript, simply execute the following script (the Unix library ImageMagick is needed, as well as the R packages ggplot2, cowplot, sf and ggpubr):

```
bash E_generate_figures.sh
```

All the figures are saved in the folder <code>figures</code>. The <code>AnimationS1</code> gif is saved in the folder gif.

## 8. Convert figures

To convert figures in png and svg format, run:

```
bash F_convert_figures.sh
```

Converted figures are saved in the folder <code>figures</code>.
