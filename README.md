OSG Connect Octave Tutorial
===========================

Overview
--------
This section covers how to use OASIS CVMFS system to run a real application like Octave or MatLab statistical package. For this example, we'll use Octave although Matlab can be substituted without any changes in the code. This example will go through using Octave to generate a random matrix, doing some simple matrix operations and then calculate the eigenvectors of the matrix.
Setup
-----
First, let's create a work directory. As always, you can use tutorial instead.
```
$ mkdir -p osg-octave/log
$ cd osg-octave
```
Testing Octave
--------------
First, we'll need to set up the system paths so we can access Octave correctly. This is done via OSG's [Distributed Environment Modules](https://confluence.grid.iu.edu/display/CON/Distributed+Environment+Modules). To access these modules, enter: 
```
$ source /cvmfs/oasis.opensciencegrid.org/osg/modules/lmod/5.6.2/init/bash
```

Now, we can load the Octave module. We'll first need to load some dependencies as well:
```
$ module load fftw/3.3.4 atlas lapack hdf5 qhull pcre SparseSuite glpk
$ module load octave
```

Once the path is set up, we can run Octave:
```
$ octave
GNU Octave, version 3.8.1
Copyright (C) 2014 John W. Eaton and others.
This is free software; see the source code for copying conditions.
There is ABSOLUTELY NO WARRANTY; not even for MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  For details, type `warranty'.
Octave was configured for "x86_64-unknown-linux-gnu".
Additional information about Octave is available at http://www.octave.org.
Please contribute if you find this software useful.
For more information, visit http://www.octave.org/get-involved.html
Read http://www.octave.org/bugs.html to learn how to submit bug reports.
For information about changes from previous versions, type `news'.
warning: X11 DISPLAY environment variable not set
warning: readline is not linked, so history control is not available
octave:1> 1+1
ans =  2
octave:2> quit()
$
```
Running Octave code
-------------------
Now let's create our Octave script. We'll call it *ex1_matrix.octave*:
```
A = rand(40, 40)
B = A' * A
[v, d] = eig(A)
diag(d)
```
Run the script:
```
$ octave ex1_matrix.octave
```
This should run fairly quickly.
Building the HTCondor job
-------------------------
Although the previous script ran quickly, suppose we needed to use a 100x100 matrix instead of a 10x10 matrix or do this a few thousand times. Since each invocation is independent of others, we can use condor to easily parallelize this and run it on OSG Connect.

First, we'll need to create a wrapper script to set up the environment for Octave before running it. Create the script *octave-wrapper.sh*:
```bash
#!/bin/bash
 
EXPECTED_ARGS=1
 
if [ $# -ne $EXPECTED_ARGS ]; then
  echo "Usage: octave-wrapper.sh file.octave"
  exit 1
else
  source /cvmfs/oasis.opensciencegrid.org/osg/palms/sw/octave/el5/x86_64/default/setup.sh
  octave $1
fi
```
 
And of course let's make this wrapper executable:
```
$ chmod +x octave-wrapper.sh
```
 
Since our previous example only ran for less than a second, let's create another significantly longer job by operating on a 1000x1000 matrix. We'll call this file *ex2_matrix.octave*:
```
A = rand(1000,1000)
B = A' * A
[v, d] = eig(A)
diag(d)
```
 
Now that we've created a wrapper and a batch job, let's build an HTCondor submit file around it. Create the file *octave.submit*:
```
universe = vanilla
log = log/octave.log.$(Cluster)
error = log/octave.err.$(Cluster).$(Process)
output = log/octave.out.$(Cluster).$(Process)
 
# Setup Octave path, run the ex2_matrix.octave script
executable = octave-wrapper.sh
transfer_input_files = ex2_matrix.octave
arguments = ex2_matrix.octave
 
requirements = (HAS_CVMFS_oasis_opensciencegrid_org =?= TRUE)
queue 100
```
Since we're using Octave from CVMFS, we will always need to have a requirement (HAS_CVMFS_oasis_opensciencegrid_org =?= TRUE) that selects nodes with CVMFS installed.
Submit and analyze
------------------
Finally, submit the job to OSG Connect!
```
$ condor_submit octave.submit
```
After a short wait, the output from the jobs will be in the ~/octave_tutorial/log/ directory.
