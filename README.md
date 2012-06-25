higgsino
========

script for calculating the cross section of pp -> chi_1+ chi_2^0 and the
branching ratios of the neutralino/chargino to h/Z, W+ for higgsino
like neutralinos.

usage
-----
- a directory "out" must be present in the main directory.
- modify my.in
- modify script.sh (adapt for loops for mu,m1,m2, path to software)
- run script.sh

results
-------
for every value of mu script.sh creates a file out/out{mu}.txt with
branching ratios and cross section.
for each out{mu}.txt sigma*br(Z)*br(W+) and sigma*br(h)*br(W+) is 
plotted with respect to M1, M2
the format of out{mu}.txt is explained in a comment in the first line.

files
-----
- my.in 
      lha file with input data (__M1__,__M2__,__MU__ are replaced)
- script.sh
      main script file. calls all other programs.
- filter.awk
      uses awk to extract all needed information from slha output of sdecay
- *.plot
      creates the plots
- sdecay.in
      configurations for sdecay

requirements
------------
- [sdecay](http://www-itp.particle.uni-karlsruhe.de/~maggie/SDECAY/)
- [softsusy](http://softsusy.hepforge.org/)
- [prospino](http://www.thphys.uni-heidelberg.de/~plehn/index.php?show=prospino&visible=tools)
- gnuplot for plots
