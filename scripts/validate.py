#!/usr/bin/env python
# coding: utf-8

import os
import sys
import subprocess
import numpy as np

### Validate class ###
class Validate:

  ### Constructor ###
  def __init__( self, model_file, input_folder, model_run, model_reps, validation_reps, validation_range ):
    #~~~~~~~~~~~~~~~~~~~~~~~~#
    # 1) Main parameters     #
    #~~~~~~~~~~~~~~~~~~~~~~~~#
    self.__model_file       = model_file
    self.__input_folder     = input_folder
    self.__model_run        = model_run
    self.__model_reps       = model_reps
    self.__validation_reps  = validation_reps
    self.__validation_range = validation_range
    #~~~~~~~~~~~~~~~~~~~~~~~~#
    # 2) Internal parameters #
    #~~~~~~~~~~~~~~~~~~~~~~~~#
    self.__models               = {}
    self.__N                    = 0
    self.__ordered_CMAES_scores = []
    self.__file_header          = ""
    self.__variables            = []
    self.__command_line         = ""
    self.__results              = {}

  ### Load the list of models ###
  def load_models( self ):
    self.__models      = {}
    self.__N           = 0
    f                  = open(self.__model_file, "r")
    self.__file_header = f.readline()
    self.__variables   = self.__file_header.strip("\n").split(" ")
    l                  = f.readline()
    while l:
      l = l.strip("\n").split(" ")
      set   = {}
      score = 0.0
      for i in range(len(self.__variables)):
        set[self.__variables[i]] = l[i]
        if self.__variables[i] == "score":
          score = float(l[i])
      if score not in self.__models.keys():
        self.__models[score] = [set]
        self.__N += 1
      else:
        self.__models[score].append(set)
        self.__N += 1
      l = f.readline()
    f.close()

  ### Build the model command line from a parameters set ###
  def __build_command_line( self, param_set ):
    self.__command_line  = self.__model_run
    self.__command_line += " -map "+self.__input_folder+"/map.txt"
    self.__command_line += " -network "+self.__input_folder+"/network.txt"
    self.__command_line += " -sample "+self.__input_folder+"/sample.txt"
    self.__command_line += " -typeofdata "+param_set["typeofdata"]
    self.__command_line += " -seed "+str(np.random.randint(1,100000000))
    self.__command_line += " -reps "+str(self.__model_reps)
    self.__command_line += " -iters "+param_set["iters"]
    self.__command_line += " -law "+param_set["law"]
    self.__command_line += " -optimfunc "+param_set["optimfunc"]
    self.__command_line += " -humanactivity "+param_set["humanactivity"]
    self.__command_line += " -xintro "+param_set["xintro"]
    self.__command_line += " -yintro "+param_set["yintro"]
    self.__command_line += " -pintro "+param_set["pintro"]
    self.__command_line += " -lambda "+param_set["lambda"]
    self.__command_line += " -mu "+param_set["mu"]
    self.__command_line += " -sigma "+param_set["sigma"]
    self.__command_line += " -gamma "+param_set["gamma"]
    self.__command_line += " -w1 "+param_set["w1"]
    self.__command_line += " -w2 "+param_set["w2"]
    self.__command_line += " -w3 "+param_set["w3"]
    self.__command_line += " -w4 "+param_set["w4"]
    self.__command_line += " -w5 "+param_set["w5"]
    self.__command_line += " -w6 "+param_set["w6"]
    self.__command_line += " -wmin "+param_set["wmin"]
    self.__command_line += "\n"

  ### Read the standard output from the model ###
  def __read_output( self, output ):
    #~~~~~~~~~~~~~~~~~~~~~~~~~#
    # 1) Read the model ouput #
    #~~~~~~~~~~~~~~~~~~~~~~~~~#
    output           = output.strip("\n").split(" ")
    likelihood       = float(output[0])
    empty_likelihood = float(output[1])
    max_likelihood   = float(output[2])
    empty_score      = float(output[3])
    score            = float(output[4])
    #~~~~~~~~~~~~~~~~~~~~~~~~~#
    # 2) Build the results    #
    #~~~~~~~~~~~~~~~~~~~~~~~~~#
    self.__results                     = {}
    self.__results["likelihood"]       = likelihood
    self.__results["empty_likelihood"] = empty_likelihood
    self.__results["max_likelihood"]   = max_likelihood
    self.__results["empty_score"]      = empty_score
    self.__results["score"]            = score

  ### Run one model session ###
  def run_model( self ):
    assert self.__command_line != "", "You must build the command line."
    model_stdout = subprocess.Popen([self.__command_line], stdout=subprocess.PIPE, shell=True)
    output       = model_stdout.stdout.read()
    self.__read_output(output)

  ### Order CMA-ES scores in a vector ###
  def __build_ordered_CMAES_scores( self ):
    self.__ordered_CMAES_scores = []
    for score in self.__models.keys():
      self.__ordered_CMAES_scores.append(score)
    self.__ordered_CMAES_scores.sort()

  ### Run the validation of CMA-ES scores ###
  def run_validation( self ):
    #~~~~~~~~~~~~~~~~~~~~~~~~~#
    # 1) Order CMA-ES scores  #
    #~~~~~~~~~~~~~~~~~~~~~~~~~#
    self.__build_ordered_CMAES_scores()
    #~~~~~~~~~~~~~~~~~~~~~~~~~#
    # 2) Open output files    #
    #~~~~~~~~~~~~~~~~~~~~~~~~~#
    f1 = open("estimations_all.txt", "w")
    f1.write("cmaes replay\n")
    f2 = open("estimations_mean.txt", "w")
    f2.write("cmaes replay_mean replay_var\n")
    f3 = open("rebuilt_list_of_parameter_sets.txt", "w")
    f3.write(self.__file_header.strip("\n")+" replay_mean replay_var empty max\n")
    #~~~~~~~~~~~~~~~~~~~~~~~~~#
    # 3) Start the validation #
    #~~~~~~~~~~~~~~~~~~~~~~~~~#
    assert self.__validation_range <= self.__N, "The validation range must be lower or equal to the total number of models."
    for i in range(self.__validation_range):
      cmaes_score = self.__ordered_CMAES_scores[i]
      for param_set in self.__models[cmaes_score]:
        mean_score  = 0.0
        var_score   = 0.0
        mean_empty  = 0.0
        mean_max    = 0.0
        print "> Score "+str(cmaes_score)+" ("+str(len(self.__models[cmaes_score]))+" model(s), "+str(round(float(i+1)/float(self.__validation_range)*100.0, 4))+"%) ..."
        for j in range(self.__validation_reps):
          #print "  - rep "+str(j+1)+" ..."
          self.__build_command_line(param_set)
          self.run_model()
          test_score  = self.__results["score"]
          test_empty  = self.__results["empty_likelihood"]
          test_max    = self.__results["max_likelihood"]
          mean_score += test_score
          var_score  += test_score*test_score
          mean_empty += test_empty
          mean_max   += test_max
          f1.write(str(cmaes_score)+" "+str(test_score)+"\n")
          f1.flush()
        mean_score /= float(self.__validation_reps)
        var_score  /= float(self.__validation_reps)
        var_score  -= mean_score*mean_score
        mean_empty /= float(self.__validation_reps)
        mean_max   /= float(self.__validation_reps)
        f2.write(str(cmaes_score)+" "+str(mean_score)+" "+str(var_score)+"\n")
        f2.flush()
        line = ""
        for var in self.__variables:
          line += str(param_set[var])+" "
        line += str(mean_score)+" "+str(var_score)+" "+str(mean_empty)+" "+str(mean_max)+"\n"
        f3.write(line)
        f3.flush()
    f1.close()
    f2.close()
    f3.close()

### Print help ###
def printHelp():
  print ""
  print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  print "                               * Validate *                                "
  print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  print "Usage: python validate.py -h or --help";
  print "   or: python validate.py [list of mandatory arguments]";
  print "Options are:"
  print "  -h, --help"
  print "        print this help, then exit"
  print "  -models, --models <list_of_models> (mandatory)"
  print "        Specify the emplacement of the file containing the list of models"
  print "  -input, --input <input files> (mandatory)"
  print "        Specify the emplacement of the input files"
  print "        (map.txt, network.txt, sample.txt)"
  print "  -model-run, --model-run <Model run executable> (mandatory)"
  print "        Specify the emplacement of model_run executable"
  print "  -model-reps, --model-reps <model_run reps> (mandatory)"
  print "        Specify the number of repetitions of each model simulation"
  print "  -validation-reps, --validation-reps <validation reps> (mandatory)"
  print "        Specify the number of repetitions for each CMA-ES validation"
  print "  -validation-range, --validation-range <validation range> (mandatory)"
  print "        Specify the validation range"
  print ""

### Print header ###
def printHeader():
  print ""
  print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  print "                               * Validate *                                "
  print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  print ""

### Read command line arguments ###
def readArgs( argv ):
  arguments                     = {}
  arguments["models"]           = ""
  arguments["input"]            = ""
  arguments["model-run"]        = ""
  arguments["model-reps"]       = 0
  arguments["validation-reps"]  = 0
  arguments["validation-range"] = 0
  provided                      = {}
  provided["models"]            = False
  provided["input"]             = False
  provided["model-run"]         = False
  provided["model-reps"]        = False
  provided["validation-reps"]   = False
  provided["validation-range"]  = False
  for i in range(len(argv)):
    if argv[i] == "-h" or argv[i] == "--help":
      printHelp()
      sys.exit()
    if argv[i] == "-models" or argv[i] == "--models":
      arguments["models"] = argv[i+1]
      provided["models"]  = True
    if argv[i] == "-input" or argv[i] == "--input":
      arguments["input"] = argv[i+1]
      provided["input"]  = True
    if argv[i] == "-model-run" or argv[i] == "--model-run":
      arguments["model-run"] = argv[i+1]
      provided["model-run"]  = True
    if argv[i] == "-model-reps" or argv[i] == "--model-reps":
      arguments["model-reps"] = int(argv[i+1])
      provided["model-reps"]  = True
    if argv[i] == "-validation-reps" or argv[i] == "--validation-reps":
      arguments["validation-reps"] = int(argv[i+1])
      provided["validation-reps"]  = True
    if argv[i] == "-validation-range" or argv[i] == "--validation-range":
      arguments["validation-range"] = int(argv[i+1])
      provided["validation-range"]  = True
  for item in provided.items():
    if not item[1]:
      print "You must provide a value for argument -"+item[0]
      sys.exit()
  return arguments

### Assert command line arguments ###
def assertArgs( arguments ):
  assert os.path.isfile(arguments["models"]), "The file "+arguments["models"]+" does not exist"
  assert os.path.isfile(arguments["input"]+"/map.txt"), "The file "+arguments["input"]+"/map.txt does not exist"
  assert os.path.isfile(arguments["input"]+"/network.txt"), "The file "+arguments["input"]+"/network.txt does not exist"
  assert os.path.isfile(arguments["input"]+"/sample.txt"), "The file "+arguments["input"]+"/sample.txt does not exist"
  assert os.path.isfile(arguments["model-run"]), "The file "+arguments["model-run"]+" does not exist"
  assert arguments["model-reps"] > 0, "The number of model run repetitions must be positive"
  assert arguments["validation-reps"] > 0, "The number of validation repetitions must be positive"
  assert arguments["validation-range"] > 0, "The validation range must be positive"


######################
#        MAIN        #
######################

if __name__ == '__main__':

  #~~~~~~~~~~~~~~~~~~~~~~~#
  # 1) Read arguments     #
  #~~~~~~~~~~~~~~~~~~~~~~~#
  arguments = readArgs(sys.argv)
  assertArgs(arguments)
  printHeader()

  #~~~~~~~~~~~~~~~~~~~~~~~#
  # 2) Run the validation #
  #~~~~~~~~~~~~~~~~~~~~~~~#
  validation = Validate(arguments["models"], arguments["input"],
                        arguments["model-run"], arguments["model-reps"],
                        arguments["validation-reps"], arguments["validation-range"])
  validation.load_models()
  validation.run_validation()

