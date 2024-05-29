#!/usr/bin/env python
# coding: utf-8

import os
import sys
import subprocess
import numpy as np

### Best model class ###
class Best_Model:

  ### Contructor ###
  def __init__( self, parameters_file, input_folder, model_run, model_reps ):
    #~~~~~~~~~~~~~~~~~~~~~~~~#
    # 1) Main parameters     #
    #~~~~~~~~~~~~~~~~~~~~~~~~#
    self.__parameters_file = parameters_file
    self.__input_folder    = input_folder
    self.__model_run       = model_run
    self.__model_reps      = model_reps
    #~~~~~~~~~~~~~~~~~~~~~~~~#
    # 2) Internal parameters #
    #~~~~~~~~~~~~~~~~~~~~~~~~#
    self.__best_model   = {}
    self.__command_line = ""
    self.__results      = {}

  ### Load the best model ###
  def load_best_model( self ):
    f                = open(self.__parameters_file, "r")
    variables        = f.readline().strip("\n").split(" ")
    l                = f.readline()
    best_replay_mean = 1e+10
    while l:
      l     = l.strip("\n").split(" ")
      model = {}
      for i in range(len(variables)):
        model[variables[i]] = l[i]
      if best_replay_mean > float(model["replay_mean"]):
        best_replay_mean  = float(model["replay_mean"])
        self.__best_model = model.copy()
      l = f.readline()
    f.close()

  ### Build model run command line from a parameters set ###
  def __build_command_line( self ):
    self.__command_line  = self.__model_run
    self.__command_line += " -map "+self.__input_folder+"/map.txt"
    self.__command_line += " -network "+self.__input_folder+"/network.txt"
    self.__command_line += " -sample "+self.__input_folder+"/sample.txt"
    self.__command_line += " -typeofdata "+self.__best_model["typeofdata"]
    self.__command_line += " -seed "+str(np.random.randint(1,100000000))
    self.__command_line += " -reps "+str(self.__model_reps)
    self.__command_line += " -iters "+self.__best_model["iters"]
    self.__command_line += " -law "+self.__best_model["law"]
    self.__command_line += " -optimfunc "+self.__best_model["optimfunc"]
    self.__command_line += " -humanactivity "+self.__best_model["humanactivity"]
    self.__command_line += " -xintro "+self.__best_model["xintro"]
    self.__command_line += " -yintro "+self.__best_model["yintro"]
    self.__command_line += " -pintro "+self.__best_model["pintro"]
    self.__command_line += " -lambda "+self.__best_model["lambda"]
    self.__command_line += " -mu "+self.__best_model["mu"]
    self.__command_line += " -sigma "+self.__best_model["sigma"]
    self.__command_line += " -gamma "+self.__best_model["gamma"]
    self.__command_line += " -w1 "+self.__best_model["w1"]
    self.__command_line += " -w2 "+self.__best_model["w2"]
    self.__command_line += " -w3 "+self.__best_model["w3"]
    self.__command_line += " -w4 "+self.__best_model["w4"]
    self.__command_line += " -w5 "+self.__best_model["w5"]
    self.__command_line += " -w6 "+self.__best_model["w6"]
    self.__command_line += " -wmin "+self.__best_model["wmin"]
    self.__command_line += " -save-outputs -save-all-states\n"

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
    self.__build_command_line()
    model_stdout = subprocess.Popen([self.__command_line], stdout=subprocess.PIPE, shell=True)
    output       = model_stdout.stdout.read()
    self.__read_output(output)

### Print help ###
def printHelp():
  print ""
  print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  print "                              * Best Model *                               "
  print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  print "Usage: python best_model.py -h or --help";
  print "   or: python best_model.py [list of mandatory arguments]";
  print "Options are:"
  print "  -h, --help"
  print "        print this help, then exit"
  print "  -validation, --validation <validated_parameters_filename> (mandatory)"
  print "        Specify the emplacement of the file containing the validated parameters"
  print "  -input, --input <input files> (mandatory)"
  print "        Specify the emplacement of the input files"
  print "        (map.txt, network.txt, sample.txt)"
  print "  -model-run, --model-run <Model run executable> (mandatory)"
  print "        Specify the emplacement of model_run executable"
  print "  -model-reps, --model-reps <model_run reps> (mandatory)"
  print "        Specify the number of repetitions of each model simulation"
  print ""

### Print header ###
def printHeader():
  print ""
  print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  print "                              * Best Model *                               "
  print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  print ""

### Read command line arguments ###
def readArgs( argv ):
  arguments               = {}
  arguments["validation"] = ""
  arguments["input"]      = ""
  arguments["model-run"]  = ""
  arguments["model-reps"] = 0
  provided                = {}
  provided["validation"]  = False
  provided["input"]       = False
  provided["model-run"]   = False
  provided["model-reps"]  = False
  for i in range(len(argv)):
    if argv[i] == "-h" or argv[i] == "--help":
      printHelp()
      sys.exit()
    if argv[i] == "-validation" or argv[i] == "--validation":
      arguments["validation"] = argv[i+1]
      provided["validation"]  = True
    if argv[i] == "-input" or argv[i] == "--input":
      arguments["input"] = argv[i+1]
      provided["input"]  = True
    if argv[i] == "-model-run" or argv[i] == "--model-run":
      arguments["model-run"] = argv[i+1]
      provided["model-run"]  = True
    if argv[i] == "-model-reps" or argv[i] == "--model-reps":
      arguments["model-reps"] = int(argv[i+1])
      provided["model-reps"]  = True
  for item in provided.items():
    if not item[1]:
      print "You must provide a value for argument -"+item[0]
      sys.exit()
  return arguments

### Assert command line arguments ###
def assertArgs( arguments ):
  assert os.path.isfile(arguments["validation"]), "The file "+arguments["validation"]+" does not exist"
  assert os.path.isfile(arguments["input"]+"/map.txt"), "The file "+arguments["input"]+"/map.txt does not exist"
  assert os.path.isfile(arguments["input"]+"/network.txt"), "The file "+arguments["input"]+"/network.txt does not exist"
  assert os.path.isfile(arguments["input"]+"/sample.txt"), "The file "+arguments["input"]+"/sample.txt does not exist"
  assert os.path.isfile(arguments["model-run"]), "The file "+arguments["model-run"]+" does not exist"
  assert arguments["model-reps"] > 0, "The number of model run repetitions must be positive"


######################
#        MAIN        #
######################

if __name__ == '__main__':

  #~~~~~~~~~~~~~~~~~~~#
  # 1) Read arguments #
  #~~~~~~~~~~~~~~~~~~~#
  arguments = readArgs(sys.argv)
  assertArgs(arguments)
  printHeader()

  #~~~~~~~~~~~~~~~~~~~#
  # 2) Run the model  #
  #~~~~~~~~~~~~~~~~~~~#
  best_model = Best_Model(arguments["validation"], arguments["input"], arguments["model-run"], arguments["model-reps"])
  best_model.load_best_model()
  best_model.run_model()

