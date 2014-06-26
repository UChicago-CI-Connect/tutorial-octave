#!/bin/bash
 
EXPECTED_ARGS=1
 
if [ $# -ne $EXPECTED_ARGS ]; then
  echo "Usage: octave-wrapper.sh file.octave"
  exit 1
else
  source /cvmfs/oasis.opensciencegrid.org/osg/palms/sw/octave/el5/x86_64/default/setup.sh
  octave $1
fi
