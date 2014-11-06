#!/bin/bash
 
  source /cvmfs/oasis.opensciencegrid.org/osg/modules/lmod/5.6.2/init/bash
  module load fftw/3.3.4 atlas lapack hdf5 qhull pcre SparseSuite glpk octave
  module load octave 
  octave $1
