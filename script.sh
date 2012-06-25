#!/bin/bash

# path to software
SOFTSUSY=/home/lo/Source/softsusy-3.3.1/softpoint.x
SDECAY=/home/lo/Source/susyhit/2/run
PROSPINO=./prospino_2.run
PROSPINODIR=/home/lo/Source/on_the_web_3_26_12/
DIR=${PWD} # working directory 

#------------------------------------------------------------------------------
# calculate branching ratios and cross section for 
#     pp -> chi_2^0 chi_1^+ -> chi_1^0 Z chi_1^0 W+
#
# This function expects 5 input parameter
# 1: Inputfile slha file. the strings __M1__, __M2__, __MU__ in inputfile 
#    are replaced by other parameters. See other 
#    parameter.
# 2: output file. The results of this function are printed linewise in this
#    file. This functions overwrites all existing files.
#    Format: 
#       M1 M2 mu N_{23}^2+N_{24}^2 m[chi_1^0] m[chi_2^0] m[chi_1^+] \
#       br(chi_2^0->chi_1^0 Z) br(chi_1^+->chi_1^0 h )br(chi_1^+-> chi_1^0 W+) \
#       sigma
# 3: M1 -- Bino-Massenparameter
# 4: M2 -- Wino-Massenparameter
# 5: mu -- Higgsino mu Parameter
function E {
	# Check Parameters
	if [ ! -f $1 ] ; then
		echo "error: input file $1 does not exist"
		return
	fi
	if ! [[ "$3" =~ ^[0-9]+([.][0-9]+)?$ ]] ; then
		echo "error: Third Parameter must be a number (Bino mass): Got $3" 
		return
	fi
	if ! [[ "$4" =~ ^[0-9]+([.][0-9]+)?$ ]] ; then
		echo "error: Third Parameter must be a number (Wino mass): Got $4" 
		return
	fi
	if ! [[ "$5" =~ ^[0-9]+([.][0-9]+)?$ ]] ; then
		echo "error: Third Parameter must be a number (mu): Got $5" 
		return
	fi
	local M1=$3
	local M2=$4
	local mu=$5
	echo "Running with M1 = $M1, M2 = $M2, mu = $mu"
	# create an input file for softsusy from input file with parameters M1, M2, mu
	sed "s/__M1__/$M1/g" < $1 | sed "s/__M2__/$M2/g" | sed "s/__MU__/$mu/g" > leshouches.in
	# Massenspektrum mit softsusy berechnen
	$SOFTSUSY leshouches < leshouches.in > SD_leshouches.in
	# calculate branching ratios with sdecay
	rm -f sdecay_slha.out
	$SDECAY

	# read results from sdecay output
	local IN=`./filter.awk sdecay_slha.out`
	# higgsino like?
	if [ "$IN" != "" ]; then 
		# calculate cross section with prospino
		echo "Running prospino..."
		cp sdecay_slha.out $PROSPINODIR/prospino.in.les_houches
		cd $PROSPINODIR # change to prospino directory so that prospino finds all needed files
		$PROSPINO
		# read cross section from first line of prospino.dat
		local IN2=`head -n 1 prospino.dat | awk '{printf "%f",$10}'`
		cd $DIR
		echo "$M1 $M2 $mu $IN $IN2" >> $2
	else
		# not higgsino like => set all values to 0.0
		echo "$M1 $M2 $mu 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0" >> $2
	fi
}

# use various values of mu, M1, M2
# write results to out{{value of mu}}.txt
for m in {350..1250..250}
do
	echo "# M1 M2 mu N_{23}^2+N_{24}^2 m[chi_1^0] m[chi_2^0] m[chi_1^+] br(chi_2^0->chi_1^0 Z) br(chi_1^+->chi_1^0 h) br(chi_1^+-> chi_1^0 W+) sigma" > "out/out$m.txt"
	for m1 in {100..2000..100} 
	do
		for m2 in {100..4100..100}
		do
			E my.in "out/out$m.txt" $m1 $m2 $m
		done
		echo "" >> "out/out$m.txt"
	done
	# create plots
	sed "s/__MU__/$m/g" < out.plot | gnuplot
	sed "s/__MU__/$m/g" < outh.plot | gnuplot
done

rm -f leshouches.in
rm -f SD_leshouches.in
