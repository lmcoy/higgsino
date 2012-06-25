#!/usr/bin/awk -f

BEGIN {
	n = 0.0
}

# nmix block: N23 & N24 ausgeben
$5 ~ /^N_/ && $1==2 && ($2==3 || $2==4) {
		# calc n_23^2 + n_24^2
		n += $3^2
}

# chi_1^+ decay
$1 ~ /^DECAY/ && $2 == 1000024, $1 ~ /^DECAY/ && $2 != 1000024 {
	#if( $1 ~ /^DECAY/ && $2 == 1000024 ) {
	#    print "~chi_1^+ decay"
	#	printf "Width = %s\n", $3 
	#}
    # branching ratio in chi_1^0 W+ 
	if( $3 == 1000022 && $4 == 24 ) {
		br_W = $1
	}
}

# chi_2^0 decay
$1 ~ /^DECAY/ && $2 == 1000023, $1 ~ /^DECAY/ && $2 != 1000023 {
	#if( $1 ~ /^DECAY/ && $2 == 1000023 ) {
	#    print "~chi_2^0 decay"
	#	printf "Width = %s\n", $3 
	#}

# branching ratio of chi_2^0 -> chi_1^0 Z/h 
	if( $3 == 1000022 && $4 == 23 ) {
		br_Z = $1
	}
	if( $3 == 1000022 && $4 == 25 ) {
		br_h = $1
	}
	#if( $1 ~ /^[0-9]/ ) {
	#	print $0
	#}
}

# mass block
$1 ~ /^BLOCK/ && $2 ~/^MASS/, $1 ~ /^BLOCK/ && $2 !~ /^MASS/ {
	# Massen der ersten Neutralinos und Charginos ermitteln
	if( $1 == 1000023 ) {
		m_chi20 = $2
	}
	if( $1 == 1000022 ) {
		m_chi10 = $2
	}
	if( $1 == 1000024 ) {
		m_chi1p = $2
	}
}

END {
	#printf "N_{23}^2 + N_{24}^2            =    %f\n", n
	#printf "m Neutralino 1                 =    %f\n", m_chi10
	#printf "m Neutralino 2                 =    %f\n", m_chi20
	#printf "m Chargino 1+                  =    %f\n", m_chi1p
	#printf "br(~chi_2^0 -> ~chi_1^0 Z)     =    %f\n", br_Z
	#printf "br(~chi_1^+ -> ~chi_1^0 W+)    =    %f\n", br_W
# print values for higgsino like neutralinos if the decay in Z/h, W+ is possible.
	if( n > 0.9 && (br_Z > 0 || br_h > 0) && br_W > 0 ) {
		printf "% 8.4e % 8.4e %8.4e %8.4e % 8.4e % 8.4e % 8.4e", n, m_chi10, m_chi20, m_chi1p, br_Z, br_h, br_W
	}
}
