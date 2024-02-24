#!/bin/bash

# Author: O.A.
# Usage: $./MINE_4_1_EV_calculator.sh

# ABOUT: CALCULATE THE EXPOSURE VALUE (EV) FOR YOUR CAMERA SETTINGS. (Film roll's reciprocity behavior for long exposures also available.)

# FORMULAS:
# * EV = Log_base2(100 * Aperture² / ISO * Shutter Speed )
#   (EV formula taken from this web page: https://www.omnicalculator.com/other/exposure)
# * Shutter Speed (s) = 100 * Aperture² / ISO * 2^EV

# Changelog:
# (2024-02-16): First idea and minimal version implemented.
# (2024-02-20): Added option to 1) Calculate ISO, Aperture, Shutter time --> EV; 2) Calculate EV, ISO, Aperture --> Shutter time; 5) Display EV table.
# (2024-02-21): Fixed calculation formulas and implementations for ISO, Aperture, Shutter time --> EV;
# 		Fixed calculation formulas and implementations for EV, ISO, Aperture --> Shutter time;
#		Implemented displaying EV table;
#		General fixes in comments and code.
#		Added option 4) Display common ISO and Aperture (F-stop) values.
#		Added option 3) Calculate Reciprocity Railure Compensation
# (2024-02-22): Implemented option 3) Calculate Reciprocity Failure Compensation
#		Today I learned...	- How to calculate with non-integer exponents in 'bc' (e.g. $(bc -l <<< "scale=4; e(1.31*l($Tm))" calculates $Tm ^ 1.31)
#					- How to "return" values from functions (using either return (some int from 0-255) or by using global variables, like r_Tc in this script.)
# (2024-02-24): Moved reciprocity calculation menu into its own function, menu_calculate_reciprocity, to prevent DRY when calculate_reciprocity is invoked from multiple places.
#		Implemented offering reciprocity compensation calculations if shutter speed / exposure time in menu choices 1 and 2 are over 1/2 s.
#		Moved code of menu_calculate_reciprocity into calculate_reciprocity to prevent DRY. Adjusted the argument requirements of calculate_reciprocity, and the parameters passed to it everywhere this function is invoked, to adapt for this adjustment.

# Outline...
# Ask user what they want to do...
# 1. Calculate ISO, Aperture (F-stop), Shutter time --> EV
# 2. Calculate EV, ISO, Aperture (F-stop) --> Shutter time
# 3. Calculate Reciprocity Failure Compensation
# 4. Show common ISO and Aperture (F-stop) values and quit
# 5. Show EV table and quit


# TODO (would be nice): Add disclaimer about me not being liable if user's photos turn out unexpected.
# TODO (could): Add some error checking for EV values input ( no less than -7. If over 20, default to 20 -- display message "defaulting to EV=20")
# TODO (could): x. Option to show different combinations of aperture/shutter time to get the same EV value?

# TODO: Before reciprocity calculation is done...
# Echo FORMULA
# Echo which values have been plugged into the formula
# Echo result to the user.
#
# TODO: Polish "read" statements to accept input on same line as the output text.

# Rounding and ceil/floor sources:
#https://duckduckgo.com/?q=bash+ceiling+function&t=brave&atb=v378-1&ia=web
#https://codechacha.com/en/shell-script-ceiling-halfup-floor/
#https://duckduckgo.com/?q=round+off+decimal+in+bash&t=brave&atb=v378-1&ia=web
#https://askubuntu.com/questions/179898/how-to-round-decimals-using-bc-in-bash

# GLOBAL VARIABLES RESERVED FOR FUNCTION RETURNS START
# r_Tc	(for returning calculated exposure time corrected for reciprocity)
# GLOBAL VARIABLES RESERVED FOR FUNCTION RETURNS END

# FUNCTION DEFINITIONS START
function EV_table(){ # A lookup table. Echoes out the selected EV value and its explanation
# expects $1 (an integer [-7, 20] or a string["title", "source", "table_header"])

case $1 in
"title")
	echo "===== EV TABLE ====="
	;;
"source")
	echo "Source: https://www.omnicalculator.com/other/exposure"
	echo ""
	;;
"table_header")
	echo "EV	Lighting condition"
	echo "--------------------------"
	;;
-7)
	echo "-7	Deep star field or the Milky Way."
	;;
-6)
	echo "-6	Night under starlight only or the Aurora Borealis."
	;;
-5)
	echo "-5	Night under crescent moon or the Aurora Borealis."
	;;
-4)
	echo "-4	Night under half moon, or a meteor shower (with long exposure duration)."
	;;
-3)
	echo "-3	Night under full moon and away from city lights."
	;;
-2)
	echo "-2	Night snowscape under full moon and away from city lights."
	;;
-1)
	echo "-1	Start (sunrise) or end (sunset) of the \"blue hour\" (outdoors) or dim ambient lighting (indoors)."
	;;
0)
	echo "0	Dim ambient artificial lighting."
	;;
1)
	echo "1	Distant view of a lit skyline."
	;;
2)
	echo "2	Under lightning (with time exposure) or a total lunar eclipse."
	;;
3)
	echo "3	Fireworks (with time exposure)."
	;;
4)
	echo "4	Candle-lit close-ups, Christmas lights, floodlight buildings, fountains, or bright street lamps."
	;;
5)
	echo "5	Home interiors at night, fairs and amusement parks."
	;;
6)
	echo "6	Brightly lit home interiors at night, fairs and amusement parks."
	;;
7)
	echo "7	Bottom of a rainforest canopy, or along brightly-lit night-time streets."
	echo "	Floodlit indoor sports areas or stadiums, and stage shows, including circuses."
	;;
8)
	echo "8	Store windows, campfires, bonfires, ice shows,"
	echo "	Floodlit indoor sports areas or stadiums, and interiors with bright fluorescent."
	;;
9)
	echo "9	Landscapes, city skylines 10 minutes after sunset, neon lights."
	;;
10)
	echo "10	Landscapes and skylines immediately after sunset, capturing a crescent moon using a long lens."
	;;
11)
	echo "11	Sunsets. Subject to deep shade."
	;;
12)
	echo "12	Open shade or heavy overcast, capturing half moon using long lens."
	;;
13)
	echo "13	Cloudy-bright light (no shadows), capturing gibbous moon using long lens."
	;;
14)
	echo "14	Weak hazy sun, rainbows (soft shadows), capturing the full moon using long lens."
	;;
15)
	echo "15	Bright or hazy sun, clear sky (distinct shadows)."
	;;
16)
	echo "16	Bright daylight on sand or snow (distinct shadows)."
	;;
17)
	echo "17	Very bright artificial lighting."
	;;
18)
	echo "18	Very bright artificial lighting."
	;;
19)
	echo "19	Very bright artificial lighting."
	;;
20)
	echo "20+	Extremely bright artificial lighting, telescopic view of the sun."
	;;
esac
}

function calculate_reciprocity() {
# Expects $1 as variable display_choice_menu, expected values are "display_choice_menu" or "don't_display_choice_menu"
# Expects $2 as variable calculation_choice, expected values are  "prompt_for_choice" or the code of a calculation choice ("A1" xor "A2" xor "A3" xor "B" xor "C")
# Expects $3 as variable Tm, expected values are "prompt_for_Tm" or a provided exposure time Tm (s)
display_choice_menu=$1
calculation_choice=$2
Tm=$3

# Self-note about calculating A^B where B is non-integer:
# "...since if x = a^b, then ln(x) = ln(a^b) = b(ln(a)), we can see that x = exp(b(ln(a))),
# so if you want to raise things to fractional b's you can use that.
#
# Note: In bc the actual exp and ln functions are e and l."
# Source https://stackoverflow.com/questions/28034126/cannot-get-complex-calculation-to-work-in-bc

# Explanation of variables in the formulas:
# Tm: Measured exposure time (s)
# Tc: Corrected exposure time (s)
# P: Reciprocity factor ("P-factor") for exposure time correction.
# Fallback reciprocity failure correction formula that is used (unless a film roll's datasheet says something else): Tc = Tm ^ P
# Source: https://www.ilfordphoto.com/wp/wp-content/uploads/2017/06/Reciprocity-Failure-Compensation.pdf

if [[ $display_choice_menu=="display_choice_menu" ]]; then
	echo "===== Reciprocity Failure Compensation ====="

	echo "A: A pre-selected film roll"
	echo "   (A1) - Fomapan 400 (reciprocity after 1/2 s)"
	echo "   (A2) - Ilford HP5+ (reciprocity after 1/2 s)"
	echo "   (A3) - T-max 400 (reciprocity after 10 s)"
	echo ""

	echo "(B): Tc = Tm ^ P formula, plug in values yourself. (Good for Ilford films)"
	echo ""

	printf "(C): Tc = Tm ^ 1.3 - A fallback, rule-of-thumb calculation. Recommended for Tm > 1 s.\n     (Aka. \"I have no clue about my film's reciprocity behavior.\")\n     Try this for...\n     - Gold 200\n     - UltraMax 400\n     - Portra 800\n     - etc."
	echo ""
fi

if [[ $calculation_choice=="prompt_for_choice" ]]; then
	echo ""
	echo "Enter choice:"
	read calculation_choice
# else use provided argument $2, already stored in variable calculation_choice, as the choice code
fi

# for menu choice 1 and 2 of this script, use provided argument as Tm
if [[ $Tm == "prompt_for_Tm" ]]; then
	echo "Enter measured exposure time Tm (s):"
	read Tm
fi


case $calculation_choice in

# A1 - Fomapan 400 (reciprocity starts after 1/2 s)
#	(My best guess according to the table in the data sheet of this film roll. I could be wrong.)
#	> 1/2 s
#	Tc = 1.5 * Tm
#	> 10 s
#	Tc = 6 * Tm
#	> 100 s
#	Tc = 8 * Tm
"A1")
	if [[ $(bc <<< "scale=4; $Tm >= 100") == 1 ]];then
		Tc=$(bc <<< "scale=4; 8 * $Tm")
	elif [[ $(bc <<< "scale=4; $Tm >= 10") == 1 ]]; then
		Tc=$(bc <<< "scale=4; 6 * $Tm")
	elif [[ $(bc <<< "scale=4; $Tm >= 1/2") == 1 ]]; then
		Tc=$(bc <<< "scale=4; 1.5 * $Tm")
	else
		echo ""
		echo "NOTE: Reciprocity compensation not needed. (Tm < 1/2 s)"
		Tc=$Tm
	fi

	# "Return" the result via a global variable
	r_Tc=$Tc
	;;

# A2 - Ilford HP5+ (reciprocity starts after 1/2 s)
	# Tc = Tm ^ 1.31 - Fetched from data sheet
"A2")
	if [[ $(bc <<< "scale=4; $Tm >= 1/2") == 1 ]]; then
		Tc=$(bc -l <<< "scale=4; e(1.31*l($Tm))") # Tc = $Tm ^ 1.31
	else
		echo ""
		echo "NOTE: Reciprocity compensation not needed. (Tm < 1/2 s)"
		Tc=$Tm
	fi

	# "Return" the result via a global variable
	r_Tc=$Tc
	;;

# A3 - T-Max 400 (reciprocity starts around 10s)
#        (My best guess according to the table in the data sheet of this film roll. I could be wrong.)
#        > 10 s
#        (Use fallback formula, because data sheet says "Change Aperture" for this measured exposure time.)
#        > 100 s
#        Tc = 3 * Tm
"A3")
	if [[ $(bc <<< "scale=4; $Tm >= 100") == 1 ]]; then # Tm >= 100 s
		Tc=$(bc <<< "scale=4; 3 * $Tm")
	elif [[ $(bc <<< "scale=4; $Tm >= 10") == 1 ]]; then # Tm >= 10 s
		echo "Recommended - Change aperture instead. (Applies to 10 s < Tm < 100 s.)"
		echo "Calculating rough exposure guess using fallback formula Tc = Tm ^ 1.3 ..."
		calculate_reciprocity "don't_display_choice_menu" "C" $Tm # returns result in global variable r_Tc
		Tc=$r_Tc
	else # if Tm < 10 s
		echo ""
		echo "NOTE: Reciprocity compensation not needed. (Tm < 10 s)"
		Tc=$Tm
	fi
	# "Return" the result via a global variable
	r_Tc=$Tc
	;;

# B  Manual Tc = Tm ^ P formula (Good for Ilford film)
#    enter Tm
#    enter P
#    return answer
"B")
	# No need to read Tm, because it is already provided as an argument to this function
	# Only need to enter P

	echo "Enter reciprocity factor P:"
	read P

	Tc=$(bc -l <<< "scale=4; e($P*l($Tm))") # $Tm ^ P

	# "Return" the result via a global variable
	r_Tc=$Tc
	;;

# C  Fallback rule-of-thumb formula
#    Tc = Tm ^ 1.3, for Tm > 1s.
#    Enter Tm
#    return answer
"C")
	Tc=$(bc -l <<< "scale=4; e(1.3*l($Tm))") # $Tm ^ 1.3

	# "Return" the result via a global variable
	r_Tc=$Tc
	;;
esac


}
# FUNCTION DEFINITIONS END

# SCRIPT STARTS HERE...
echo "===== Simple EV calculator ====="
echo ""
echo "I want to calculate..."
echo ""
echo "1. ISO, Aperture, Shutter Speed --> EV"
echo "2. EV, ISO, Aperture --> Shutter speed (exposure time) [This option is good for long exposure situations.]"
echo "3. Reciprocity Failure Compensation"
echo "4. Display common ISO and Aperture (F-stop) values"
echo "5. Display EV table"
echo ""

echo "Enter choice:"
read menu_choice
echo ""

if [[ $menu_choice == 1 ]]; then
	# Calculate ISO, Aperture (F-Stop), Shutter time --> EV

	# Ask for inputs
	# Do calculations
	# Print results

	echo "===== Calculate ISO, Aperture, Shutter Speed --> EV ====="
	echo "Formula: EV = Log_base2( 100 * aperture² / ISO * shutter speed )"
	echo ""

	echo "Enter film's ISO:"
	read ISO

	echo "Enter Aperture (F-Stop):"
	read aperture

	echo "Enter Shutter Speed (s) (without reciprocity failure compensation):"
	read shutter_speed

	# dummy values (debug and demoing)
	# ISO=400
	# aperture=11
	# shutter_speed=0,01
	# Gives EV = 11.56, aka EV is 11 or 12

	aperture_squared=$( bc -l <<< "scale=4; $aperture^2" )
	aperture_over_exposure_time=$( bc -l <<< "scale=4; ((100 * $aperture_squared)/($ISO * $shutter_speed))" ) # the division we will take the logarithm of
	EV=$(bc -l <<< "scale=4; l($aperture_over_exposure_time)/l(2)") # calculates the base-2 logarithm
	echo ""
	echo "EV = $EV"

	# Round value and display an explanation of calculated EV value.
	EV_rounded=$(/usr/bin/printf "%.0f" $EV)
	# python3 -c "print(round(3.4))" # Alternative solution for rounding
	echo "Suitable for this lighting situation..."
	EV_table $EV_rounded

	# IF ENTERED EXPOSURE TIME IS > 1/2 S, OFFER TO CALCULATE RECIPROCITY FAILURE COMPENSATION Tc
	echo ""
	exposure_time=$shutter_speed
	if [[ $(bc <<< "scale=4; $exposure_time > 1/2") == 1 ]]; then
		echo "Exposure time is above 1/2 s. Calculate reciprocity failure compensation? (y/N):"

		read calculate_reciprocity_y_n
		if [[ $calculate_reciprocity_y_n == "y" ]]; then
			calculate_reciprocity "display_choice_menu" "prompt_for_choice" $exposure_time # returns result in global variable r_Tc
			echo ""
			echo "Corrected exposure time Tc = $r_Tc s"
		fi
	fi


elif [[ $menu_choice == 2 ]]; then
	# Calculate EV, ISO, Aperture (F-stop) --> Shutter time

	# Ask for inputs
	# Do calculations
	# Print results

	echo "===== Calculate EV, ISO, Aperture --> Shutter speed (exposure time) ====="
	echo "Formula: Shutter speed (s) = 100 * Aperture² / ISO * 2^EV"
	echo ""

	echo "Enter EV:"
	read EV

	echo "Enter film's ISO:"
	read ISO

	echo "Enter Aperture (F-Stop):"
	read aperture

	aperture_squared=$( bc -l <<< "scale=4; $aperture^2" )
	two_to_power_of_EV=$( bc -l <<< "scale=4; 2^$EV ") # works because $EV is always expected to be an integer, in our use case. Different approach would be neded if EV was non-integer
	exposure_time=$( bc -l <<< "scale=4; ((100 * $aperture_squared)/($ISO * $two_to_power_of_EV))" )
	echo ""
	echo "Exposure time = $exposure_time seconds."

	# IF EXPOSURE TIME IS > 1/2 S, OFFER TO CALCULATE RECIPROCITY FAILURE COMPENSATION Tc
	if [[ $(bc <<< "scale=4; $exposure_time > 1/2") == 1 ]]; then
		echo "Exposure time is above 1/2 s. Calculate reciprocity failure compensation? (y/N):"

		read calculate_reciprocity_y_n
		echo ""

		if [[ $calculate_reciprocity_y_n == "y" ]]; then
			calculate_reciprocity "display_choice_menu" "prompt_for_choice" $exposure_time # returns result in global variable r_Tc
			echo ""
			echo "Corrected exposure time Tc = $r_Tc s"
		fi
	fi

elif [[ $menu_choice == 3 ]]; then
	# Calculate Reciprocity Failure Compensation
	calculate_reciprocity "display_choice_menu" "prompt_for_choice" "prompt_for_Tm" # returns result in global variable r_Tc
	echo ""
	echo "Corrected exposure time Tc = $r_Tc s"

elif [[ $menu_choice == 4 ]]; then
	# Display common ISO and Aperture (F-Stop) values and quit

	echo "===== Common ISO (film speed) and Aperture (F-stop) values ====="
	echo ""

	echo "--- ISO ---"
	printf "Slow speeds: \nISO 50 \nISO 100-125 \nISO 200"
	echo ""
	echo ""

	printf "Medium speed: \nISO 400"
	echo ""
	echo ""

	printf "Fast speeds: \nISO 800 \nISO 1600\nISO 3200"
	echo ""
	echo ""

	echo "Sources - \"Film ISO - A beginners guide by ILFORD Photo\""
	echo "          https://www.youtube.com/watch?v=AQ9rwLC8yqs"
	echo "        - \"When to Use Different ISO Film Speeds\", Guide to Film Photography"
	echo "          https://www.guidetofilmphotography.com/film-speed-uses.html"
	echo ""

	echo "--- Common Aperture (F-stop) values ---"
	echo "f/1"
	echo "f/1.4"
	echo "f/2"
	echo "f/2.8"
	echo "f/4"
	echo "f/5.6"
	echo "f/8"
	echo "f/11"
	echo "f/16"
	echo "f/22"
	echo "f/32"

	echo ""
	echo "Source - \"F Stop Chart: Lens Apertures for Full Stops, 1/2 Stops & 1/3 Stops\", Have Camera, Will Travel"
	echo "         https://havecamerawilltravel.com/f-stop-chart-lens-apertures/"
	echo ""

elif [[ $menu_choice == 5 ]]; then
	# Display EV table and quit

	for EV_value in "title" "source" "table_header" {-7..20};
	do
		EV_table $EV_value
	done
else
	echo "Bad input."
fi

echo ""
