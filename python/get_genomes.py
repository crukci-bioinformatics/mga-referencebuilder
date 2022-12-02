#!/usr/bin/env python3

import sys
import time
import os
import os.path
import subprocess

###############################################################################

def retrieve(url):
  last = os.path.basename(url)
  full = url+"/"+last+"_genomic.fna.gz"
  cmd = ["wget","-q",full]
  proc = subprocess.Popen(cmd)
  proc.wait()
  
###############################################################################

sources = sys.argv[1]
os.chdir(sys.argv[2])
fd = open(sources)
fd.readline() # get rid of header
for line in fd:
  flds = line.strip().split("\t")
  retrieve(flds[6])
  sys.stderr.write("Retrieved %s %s...\n" % (flds[0],flds[3]))
  time.sleep(3)
