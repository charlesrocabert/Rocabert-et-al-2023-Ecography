#!/usr/bin/env python
# coding: utf-8

import os
import sys
import time
import subprocess
import numpy as np

### Evaluate2 class ###
class Evaluate2:

  ### Contructor ###
  def __init__( self, parameters_file, input_folder, model_run, model_score, model_reps, nb_params ):
    #~~~~~~~~~~~~~~~~~~~~~~~~#
    # 1) Main parameters     #
    #~~~~~~~~~~~~~~~~~~~~~~~~#
    self.__parameters_file = parameters_file
    self.__input_folder    = input_folder
    self.__model_run       = model_run
    self.__model_score     = model_score
    self.__model_reps      = model_reps
    self.__nb_params       = nb_params

    #~~~~~~~~~~~~~~~~~~~~~~~~#
    # 2) Internal parameters #
    #~~~~~~~~~~~~~~~~~~~~~~~~#
    self.__best_model   = {}
    self.__command_line = ""

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

  ### Build model_run command line from a parameters set ###
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

  ### Run one complete evaluation ###
  def complete_evaluation( self ):
    self.__build_command_line()
    model_stdout = subprocess.Popen([self.__command_line], stdout=subprocess.PIPE, shell=True)
    command_line = "Rscript "+self.__model_score+" "+os.getcwd()+" "+str(self.__best_model["iters"])+" "+str(self.__nb_params)+"\n"
    os.system(command_line)

### Print help ###
def printHelp():
  print ""
  print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  print "                          * Complete Evaluation *                          "
  print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  print "Usage: python complete_evaluation.py -h or --help";
  print "   or: python complete_evaluation.py [list of mandatory arguments]";
  print "Options are:"
  print "  -h, --help"
  print "        print this help, then exit"
  print "  -validation, --validation <validated_parameters_filename> (mandatory)"
  print "        Specify the emplacement of the file containing the validated parameters"
  print "  -input, --input <input files> (mandatory)"
  print "        Specify the emplacement of the input files"
  print "        (map.txt, network.txt, sample.txt)"
  print "  -model-run, --model-run <model_run executable> (mandatory)"
  print "        Specify the emplacement of model_run executable"
  print "  -model-score, --model-score <model score> (mandatory)"
  print "        Specify the emplacement of complete_evaluation.R script"
  print "  -model-reps, --model-reps <model_run reps> (mandatory)"
  print "        Specify the number of repetitions of each model simulation"
  print "  -score-reps, --score-reps <SCORE reps> (mandatory)"
  print "        Specify the number of repetitions to compute score distributions"
  print "  -nb-params, --nb-params <Nb parameters> (mandatory)"
  print "        Specify the number of optimized parameters"
  print ""

### Print header ###
def printHeader():
  print ""
  print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  print "                          * Complete Evaluation *                          "
  print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  print ""

### Read command line arguments ###
def readArgs( argv ):
  arguments                = {}
  arguments["validation"]  = ""
  arguments["input"]       = ""
  arguments["model-run"]   = ""
  arguments["model-score"] = ""
  arguments["model-reps"]  = 0
  arguments["score-reps"]  = 0
  arguments["nb-params"]   = 0
  provided                 = {}
  provided["validation"]   = False
  provided["input"]        = False
  provided["model-run"]    = False
  provided["model-score"]  = False
  provided["model-reps"]   = False
  provided["score-reps"]   = False
  provided["nb-params"]    = False
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
    if argv[i] == "-model-score" or argv[i] == "--model-score":
      arguments["model-score"] = argv[i+1]
      provided["model-score"]  = True
    if argv[i] == "-model-reps" or argv[i] == "--model-reps":
      arguments["model-reps"] = int(argv[i+1])
      provided["model-reps"]  = True
    if argv[i] == "-score-reps" or argv[i] == "--score-reps":
      arguments["score-reps"] = int(argv[i+1])
      provided["score-reps"]  = True
    if argv[i] == "-nb-params" or argv[i] == "--nb-params":
      arguments["nb-params"] = int(argv[i+1])
      provided["nb-params"]  = True
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
  assert os.path.isfile(arguments["model-score"]), "The file "+arguments["model-score"]+" does not exist"
  assert arguments["model-reps"] > 0, "The number of model_run repetitions must be positive"
  assert arguments["score-reps"] > 0, "The number of score repetitions must be positive"
  assert arguments["nb-params"] > 0, "The number of optimized parameters must be positive"


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
  f = open("complete_evaluation_all.txt", "w")
  for i in range(arguments["score-reps"]):
    print("> Repetition "+str(i+1)+"/"+str(arguments["score-reps"]))
    sim = Evaluate2(arguments["validation"], arguments["input"], arguments["model-run"], arguments["model-score"], arguments["model-reps"], arguments["nb-params"])
    sim.load_best_model()
    results = sim.complete_evaluation()
    g       = open("complete_evaluation.txt", "r")
    l       = g.readline()
    if i == 0:
      f.write("rep "+l)
    l = g.readline()
    while l:
      f.write(str(i+1)+" "+l)
      l = g.readline()
    g.close()
    f.flush()
    time.sleep(1)
  f.close()

