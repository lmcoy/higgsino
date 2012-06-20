#!/bin/bash
SOFTSUSY=/home/lo/Source/softsusy-3.3.1/softpoint.x
SDECAY=/home/lo/Source/susyhit/2/run
PROSPINO=./prospino_2.run
PROSPINODIR=/home/lo/Source/on_the_web_3_26_12/
DIR=${PWD} # aktuelles working dir ermitteln


#------------------------------------------------------------------------------
# Berechne branching ratios und Wirkungsquerschnitt für 
#     pp -> chi_2^0 chi_1^+ -> chi_1^0 Z chi_1^0 W+
#
# Die Funktion erwartet 5 Inputparameter
# 1: Inputfile slha file. Die Strings __M1__, __M2__, __MU__ im Inputfile 
#    werden in dieser Funktion durch neue Parameter ersetzt. Siehe andere 
#    Parameter.
# 2: Ausgabedatei. In diese Datei werden die Ergebnisse der Funktion
#    zeilenweise geschrieben. Vorhandene Dateien werden überschrieben.
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
	# Werte für M1, M2 und mu in input-Datei eintragen
	sed "s/__M1__/$M1/g" < $1 | sed "s/__M2__/$M2/g" | sed "s/__MU__/$mu/g" > leshouches.in
	# Massenspektrum mit softsusy berechnen
	$SOFTSUSY leshouches < leshouches.in > SD_leshouches.in
	# branching ratios mit sdecay berechnen
	rm -f sdecay_slha.out
	$SDECAY

	# Gesuchte Werte aus dem Resultat von sdecay auslesen
	local IN=`./filter.awk sdecay_slha.out`
	# Ist Higgsino & Zerfälle möglich?
	if [ "$IN" != "" ]; then 
		# Wirkungsquerschnitt mit Prospino berechnen
		echo "Running prospino..."
		cp sdecay_slha.out $PROSPINODIR/prospino.in.les_houches
		cd $PROSPINODIR # Prospino muss in seinem Verzeichnis aufgerufen werden, um alle Dateien zu finden.
		$PROSPINO
		# Der Wirkungsquerschnitt steht in der 1. Zeile von prospino.dat
		local IN2=`head -n 1 prospino.dat | awk '{printf "%f",$10}'`
		cd $DIR
		echo "$M1 $M2 $mu $IN $IN2" >> $2
	else
		# Nicht relevanter Bereich => Setze alle Werte auf 0
		echo "$M1 $M2 $mu 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0" >> $2
	fi
}

# Durchlaufe verschiedene Werte für mu, M1, M2
# Schreibe Ergebnisse in Datei out{{Wert von mu}}.txt
for m in {600..700..250}
do
	echo "# M1 M2 mu N_{23}^2+N_{24}^2 m[chi_1^0] m[chi_2^0] m[chi_1^+] br(chi_2^0->chi_1^0 Z) br(chi_1^+->chi_1^0 h) br(chi_1^+-> chi_1^0 W+) sigma" > "out/out$m.txt"
	for m1 in {100..500..10} 
	do
		for m2 in {500..3500..100}
		do
			E my.in "out/out$m.txt" $m1 $m2 $m
		done
		echo "" >> "out/out$m.txt"
	done
	# Plot erzeugen
	sed "s/__MU__/$m/g" < out.plot | gnuplot
	sed "s/__MU__/$m/g" < outh.plot | gnuplot
done

rm -f leshouches.in
rm -f SD_leshouches.in
