#include "../cmake/Config.h"

#include <unistd.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstring>
#include <vector>
#include <unordered_map>
#include <sys/stat.h>
#include <gsl/gsl_multimin.h>
#include <assert.h>

#include "./lib/Parameters.h"
#include "./lib/Simulation.h"

void printUsage( void );
void readArgs( int argc, char const** argv, Parameters* parameters );
void create_output_folder( void );


/**
 * \brief    main function
 * \details  --
 * \param    int argc
 * \param    char const** argv
 * \return   \e int
 */
int main(int argc, char const** argv)
{
  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  /* 1) Read command line arguments and load parameters */
  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  Parameters* parameters = new Parameters();
  readArgs(argc, argv, parameters);
  if (parameters->saveOutputs())
  {
    create_output_folder();
    parameters->write_parameters("output/parameters.txt");
  }

  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  /* 2) Create the simulation                           */
  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  Simulation* simulation = new Simulation(parameters);

  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  /* 3) Run the simulation                              */
  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  while (simulation->get_iteration() < parameters->get_iterations())
  {
    if (parameters->saveAllStates())
    {
      std::stringstream filename;
      filename << "output/state_" << simulation->get_iteration() << ".txt";
      simulation->write_state(filename.str());
    }
    simulation->compute_next_iteration();
  }

  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  /* 4) Compute the score and save the final state      */
  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  simulation->compute_score();
  if (parameters->saveOutputs())
  {
    simulation->write_state("output/final_state.txt");
    //simulation->write_invasion_euclidean_distributions("output/observed_euclidean_distribution.txt", "output/simulated_euclidean_distribution.txt");
  }

  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  /* 5) Return the score, free the memory and exit      */
  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  double likelihood       = simulation->get_total_log_likelihood();
  double empty_likelihood = simulation->get_total_log_empty_likelihood();
  double max_likelihood   = simulation->get_total_log_maximum_likelihood();
  double empty_score      = simulation->get_empty_score();
  double score            = simulation->get_score();
  delete simulation;
  simulation = NULL;
  delete parameters;
  parameters = NULL;
  std::cout << likelihood << " " << empty_likelihood << " " << max_likelihood << " " << empty_score << " " << score << "\n";
  return EXIT_SUCCESS;
}

/**
 * \brief    Read arguments
 * \details  --
 * \param    int argc
 * \param    char const** argv
 * \param    Parameters* parameters
 * \return   \e void
 */
void readArgs( int argc, char const** argv, Parameters* parameters )
{
  std::unordered_map<std::string, bool> options;
  options["seed"]          = false;
  options["typeofdata"]    = false;
  options["network"]       = false;
  options["map"]           = false;
  options["sample"]        = false;
  options["reps"]          = false;
  options["iters"]         = false;
  options["law"]           = false;
  options["optimfunc"]     = false;
  options["humanactivity"] = false;
  options["xintro"]        = false;
  options["yintro"]        = false;
  options["pintro"]        = false;
  options["lambda"]        = false;
  options["mu"]            = false;
  options["sigma"]         = false;
  options["gamma"]         = false;
  options["w1"]            = false;
  options["w2"]            = false;
  options["w3"]            = false;
  options["w4"]            = false;
  options["w5"]            = false;
  options["w6"]            = false;
  options["wmin"]          = false;
  for (int i = 0; i < argc; i++)
  {
    if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0)
    {
      printUsage();
      exit(EXIT_SUCCESS);
    }
    if (strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "--version") == 0)
    {
      std::cout << PACKAGE << " (" << VERSION_MAJOR << "." << VERSION_MINOR << "." << VERSION_PATCH << ")\n";
      exit(EXIT_SUCCESS);
    }
    if (strcmp(argv[i], "-seed") == 0 || strcmp(argv[i], "--seed") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: command seed value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_prng_seed((unsigned)atol(argv[i+1]));
        options["seed"] = true;
      }
    }
    if (strcmp(argv[i], "-map") == 0 || strcmp(argv[i], "--map") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: map filename is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_map_filename(argv[i+1]);
        options["map"] = true;
      }
    }
    if (strcmp(argv[i], "-network") == 0 || strcmp(argv[i], "--network") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: network filename is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_network_filename(argv[i+1]);
        options["network"] = true;
      }
    }
    if (strcmp(argv[i], "-sample") == 0 || strcmp(argv[i], "--sample") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: sample filename is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_sample_filename(argv[i+1]);
        options["sample"] = true;
      }
    }
    if (strcmp(argv[i], "-typeofdata") == 0 || strcmp(argv[i], "--type-of-data") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: typeofdata parameter is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        options["typeofdata"] = true;
        if (strcmp(argv[i+1], "PRESENCE_ONLY") == 0)
        {
          parameters->set_typeofdata(PRESENCE_ONLY);
        }
        else if (strcmp(argv[i+1], "PRESENCE_ABSENCE") == 0)
        {
          parameters->set_typeofdata(PRESENCE_ABSENCE);
        }
        else
        {
          std::cout << "Error: wrong typeofdata value.\n";
          exit(EXIT_FAILURE);
        }
      }
    }
    if (strcmp(argv[i], "-reps") == 0 || strcmp(argv[i], "--reps") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: reps value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_repetitions(atoi(argv[i+1]));
        options["reps"] = true;
      }
    }
    if (strcmp(argv[i], "-iters") == 0 || strcmp(argv[i], "--iters") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: iters value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_iterations(atoi(argv[i+1]));
        options["iters"] = true;
      }
    }
    if (strcmp(argv[i], "-law") == 0 || strcmp(argv[i], "--law") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: law name is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        options["law"] = true;
        if (strcmp(argv[i+1], "DIRAC") == 0)
        {
          parameters->set_jump_law(DIRAC);
        }
        else if (strcmp(argv[i+1], "NORMAL") == 0)
        {
          parameters->set_jump_law(NORMAL);
        }
        else if (strcmp(argv[i+1], "LOG_NORMAL") == 0)
        {
          parameters->set_jump_law(LOG_NORMAL);
        }
        else if (strcmp(argv[i+1], "CAUCHY") == 0)
        {
          parameters->set_jump_law(CAUCHY);
        }
        else
        {
          std::cout << "Error: wrong law value.\n";
          exit(EXIT_FAILURE);
        }
      }
    }
    if (strcmp(argv[i], "-optimfunc") == 0 || strcmp(argv[i], "--optimfunc") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: optimfunc name is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        options["optimfunc"] = true;
        if (strcmp(argv[i+1], "LSS") == 0)
        {
          parameters->set_optimization_function(LSS);
        }
        else if (strcmp(argv[i+1], "LOG_LIKELIHOOD") == 0)
        {
          parameters->set_optimization_function(LOG_LIKELIHOOD);
        }
        else if (strcmp(argv[i+1], "LIKELIHOOD_LSS") == 0)
        {
          parameters->set_optimization_function(LIKELIHOOD_LSS);
        }
        else
        {
          std::cout << "Error: wrong optimfunc value.\n";
          exit(EXIT_FAILURE);
        }
      }
    }
    if (strcmp(argv[i], "-humanactivity") == 0 || strcmp(argv[i], "--humanactivity") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: humanactivity name is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        options["humanactivity"] = true;
        if (strcmp(argv[i+1], "NO") == 0)
        {
          parameters->set_human_activity_index(false);
        }
        else if (strcmp(argv[i+1], "YES") == 0)
        {
          parameters->set_human_activity_index(true);
        }
        else
        {
          std::cout << "Error: wrong humanactivity value.\n";
          exit(EXIT_FAILURE);
        }
      }
    }
    if (strcmp(argv[i], "-xintro") == 0 || strcmp(argv[i], "--xintro") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: xintro value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_x_introduction(atof(argv[i+1]));
        options["xintro"] = true;
      }
    }
    if (strcmp(argv[i], "-yintro") == 0 || strcmp(argv[i], "--yintro") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: yintro value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_y_introduction(atof(argv[i+1]));
        options["yintro"] = true;
      }
    }
    if (strcmp(argv[i], "-pintro") == 0 || strcmp(argv[i], "--pintro") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: pintro value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_p_introduction(atof(argv[i+1]));
        options["pintro"] = true;
      }
    }
    if (strcmp(argv[i], "-lambda") == 0 || strcmp(argv[i], "--lambda") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: lambda value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_lambda(atof(argv[i+1]));
        options["lambda"] = true;
      }
    }
    if (strcmp(argv[i], "-mu") == 0 || strcmp(argv[i], "--mu") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: mu value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_mu(atof(argv[i+1]));
        options["mu"] = true;
      }
    }
    if (strcmp(argv[i], "-sigma") == 0 || strcmp(argv[i], "--sigma") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: sigma value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_sigma(atof(argv[i+1]));
        options["sigma"] = true;
      }
    }
    if (strcmp(argv[i], "-gamma") == 0 || strcmp(argv[i], "--gamma") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: gamma value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_gamma(atof(argv[i+1]));
        options["gamma"] = true;
      }
    }
    if (strcmp(argv[i], "-w1") == 0 || strcmp(argv[i], "--w1") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: w1 value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_w1(atof(argv[i+1]));
        options["w1"] = true;
      }
    }
    if (strcmp(argv[i], "-w2") == 0 || strcmp(argv[i], "--w2") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: w2 value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_w2(atof(argv[i+1]));
        options["w2"] = true;
      }
    }
    if (strcmp(argv[i], "-w3") == 0 || strcmp(argv[i], "--w3") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: w3 value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_w3(atof(argv[i+1]));
        options["w3"] = true;
      }
    }
    if (strcmp(argv[i], "-w4") == 0 || strcmp(argv[i], "--w4") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: w4 value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_w4(atof(argv[i+1]));
        options["w4"] = true;
      }
    }
    if (strcmp(argv[i], "-w5") == 0 || strcmp(argv[i], "--w5") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: w5 value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_w5(atof(argv[i+1]));
        options["w5"] = true;
      }
    }
    if (strcmp(argv[i], "-w6") == 0 || strcmp(argv[i], "--w6") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: w6 value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_w6(atof(argv[i+1]));
        options["w6"] = true;
      }
    }
    if (strcmp(argv[i], "-wmin") == 0 || strcmp(argv[i], "--wmin") == 0)
    {
      if (i+1 == argc)
      {
        std::cout << "Error: wmin value is missing.\n";
        exit(EXIT_FAILURE);
      }
      else
      {
        parameters->set_wmin(atof(argv[i+1]));
        options["wmin"] = true;
      }
    }
    if (strcmp(argv[i], "-save-outputs") == 0 || strcmp(argv[i], "--save-outputs") == 0)
    {
      parameters->set_save_outputs(true);
    }
    if (strcmp(argv[i], "-save-all-states") == 0 || strcmp(argv[i], "--save-all-states") == 0)
    {
      parameters->set_save_all_states(true);
    }
  }
  bool parameter_lacking = false;
  for (auto it = options.begin(); it != options.end(); ++it)
  {
    if (!it->second)
    {
      std::cout << "-" << it->first << " option is mandatory.\n";
      parameter_lacking = true;
    }
  }
  if (parameter_lacking)
  {
    exit(EXIT_FAILURE);
  }
  options.clear();
}

/**
 * \brief    Print usage
 * \details  --
 * \param    void
 * \return   \e void
 */
void printUsage( void )
{
  std::cout << "\n";
  std::cout << "***************************************************************************\n";
#ifdef DEBUG
  std::cout << " " << PACKAGE << " " << VERSION_MAJOR << "." << VERSION_MINOR << "." << VERSION_PATCH << " ( debug )\n";
#endif
#ifdef NDEBUG
  std::cout << " " << PACKAGE << " " << VERSION_MAJOR << "." << VERSION_MINOR << "." << VERSION_PATCH << " ( release )\n";
#endif
  std::cout << "***************************************************************************\n";
  std::cout << "Usage: HMD_model_run -h or --help\n";
  std::cout << "   or: HMD_model_run [list of mandatory parameters]\n";
  std::cout << "Options are:\n";
  std::cout << "  -h, --help\n";
  std::cout << "        print this help, then exit\n";
  std::cout << "  -v, --version\n";
  std::cout << "        print the current version, then exit\n";
  std::cout << "  -seed, --seed <seed>\n";
  std::cout << "        Specify the prng seed\n";
  std::cout << "  -typeofdata, --type-of-data <typeofdata>\n";
  std::cout << "        Specify the type of experimental data (PRESENCE_ONLY or PRESENCE_ABSENCE)\n";
  std::cout << "  -network, --network <filename>\n";
  std::cout << "        Specify the network file (default: network.txt)\n";
  std::cout << "  -map, --map <filename>\n";
  std::cout << "        Specify the map file (default: map.txt)\n";
  std::cout << "  -sample, --sample <filename>\n";
  std::cout << "        Specify the sample file (default: sample.txt)\n";
  std::cout << "  -reps, --reps <repetitions>\n";
  std::cout << "        Specify the number of repetitions by simulation\n";
  std::cout << "  -iters, --iters <iterations>\n";
  std::cout << "        Specify the number of iterations by simulation\n";
  std::cout << "  -law, --law <law>\n";
  std::cout << "        Specify the jump distribution law (DIRAC, NORMAL, LOG_NORMAL, CAUCHY)\n";
  std::cout << "  -optimfunc, --optimfunc <optimization_function>\n";
  std::cout << "        Specify the optimization function (LSS, LOG_LIKELIHOOD, LIKELIHOOD_LSS)\n";
  std::cout << "  -humanactivity, --humanactivity <human_activity_index>\n";
  std::cout << "        Specify if the human activity index should be used to weight the number of jump events (NO, YES)\n";
  std::cout << "  -xintro, --xintro <coordinate>\n";
  std::cout << "        Specify the x coordinate of the introduction cell\n";
  std::cout << "  -yintro, --yintro <coordinate>\n";
  std::cout << "        Specify the y coordinate of the introduction cell\n";
  std::cout << "  -pintro, --pintro <p-intro>\n";
  std::cout << "        Specify the prevalence of introduction\n";
  std::cout << "  -lambda, --lambda <lambda>\n";
  std::cout << "        Specify the mean number of jumps per cell per year\n";
  std::cout << "  -mu, --mu <mu>\n";
  std::cout << "        Specify the mean of the jump distribution (with DIRAC, NORMAL, LOG_NORMAL)\n";
  std::cout << "  -sigma, --sigma <sigma>\n";
  std::cout << "        Specify the variance of the jump distribution (with NORMAL, LOG_NORMAL)\n";
  std::cout << "  -gamma, --gamma <gamma>\n";
  std::cout << "        Specify the gamma parameter of the jump distribution (with CAUCHY)\n";
  std::cout << "  -w1, --w1 <weight>\n";
  std::cout << "        Specify the weight of category I roads\n";
  std::cout << "  -w2, --w2 <weight>\n";
  std::cout << "        Specify the weight of category II roads\n";
  std::cout << "  -w3, --w3 <weight>\n";
  std::cout << "        Specify the weight of category III roads\n";
  std::cout << "  -w4, --w4 <weight>\n";
  std::cout << "        Specify the weight of category IV roads\n";
  std::cout << "  -w5, --w5 <weight>\n";
  std::cout << "        Specify the weight of category V roads\n";
  std::cout << "  -w6, --w6 <weight>\n";
  std::cout << "        Specify the weight of category VI roads\n";
  std::cout << "  -wmin, --wmin <weight>\n";
  std::cout << "        Specify the minimal weight between cells\n";
  std::cout << "  -save-outputs, --save-outputs\n";
  std::cout << "        Save simulation outputs (final state, lineage tree, ...)\n";
  std::cout << "  -save-all-states, --save--all-states\n";
  std::cout << "        Save simulation state at any time\n";
  std::cout << "\n";
}

/**
 * \brief    Create outputs folder
 * \details  --
 * \param    void
 * \return   \e void
 */
void create_output_folder( void )
{
  system("rm -rf output");
  system("mkdir output");
}
