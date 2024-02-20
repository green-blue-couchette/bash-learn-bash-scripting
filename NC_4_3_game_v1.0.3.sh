#!/bin/bash

# Author: O.A.
# Usage: $./NC_4_3_game_v1.0.3.sh

# Tutorial followed: https://www.youtube.com/watch?v=Fq6gqi9Ubog&list=PLIhvC56v63IKioClkSNDjW7iz-6TFvLwS&index=4
# Introduces concepts of CONDITIONALS, NESTED CONDITIONALS, CASES
# UPDATE (19-02-2024): Also uses FUNCTION CALLS

# UPDATE (19-02-2024): Added check for user "bernard" to the 2nd attack round.
# UPDATE (19-02-2024): Replaced DRY-breaking attack reprompt code with while-loops in both battle rounds.
# UPDATE (19-02-2024): Added easy/medium/hard indicators for player choice screen.
# UPDATE (19-02-2024): Replaced the "divine help" code blocks with function calls to eliminate breaking DRY principle.
# UPDATE (19-02-2024): Change all custom (non-env-variable) multiword variable names to snake_case.
# UPDATE (20-02-2024): Moved the battle code inside a function. Also refactored that code to conditionally require user to be logged in as "root".

# - CONDITIONALS (aka. "if" statements)
# if [[ some condition ]]; then
# 	(some code)
# elif [[ some condition ]]; then
#	(some code)
# else
#	(some code)
# fi
# NOTE: MAKE SURE TO KEEP THE BLANK SPACE BETWEEN "some condition" and the closing "]]".


# - CONDITIONALS ("case" statements)
# read some_variable (supposing that some_variable takes only numeric values)
# case $somevariable in
# 1)
#	(do something)
#	;;
# 2)
#	(do something)
#	;;
# 3)
#	(do something)
#	;;
# esac

#--- Function definitions START
# expects $1 (a number)

function divine_help() {
# expects argument at $1. Should be the beast value.
	case $divine_help in
		"always")
			echo "Divine help: Choose $1!"
			echo "You're always blessed with divine help!"
			;;

		"sometimes")
			# calculate divine help (50% chance)
			# if yes, echo it.
			if [[ $(( $RANDOM % 10 )) > 4 ]]; then
				echo "Divine help: Choose $1!"
				echo "SOMETIMES you get divine help. You just don't know where it comes from."
			fi
			;;

		"rarely")
			# calculate divine help (10% chance)
			# if yes, echo it
			if [[ $(( $RANDOM % 10 )) > 8 ]]; then
				echo "Divine help: Choose $1!"
				echo "You RARELY get divine help, but you're so glad when you do."
			fi
			;;
	esac
}

function battle() {
# expects $1 beast_value	(a number)
# expects $2 root_required	("root_required" or anything else, e.g. "root_not_required")
# expects $3 player_strength	(the strength string set at the start of the game)
beast_value=$1
root_required=$2
player_strength=$3

# "coffee" is a secret code for winning an attack
attacks=0
while true
do
	read my_value

	if [[ $USER == "bernard" ]]; then
	        echo "Hey, Bernard always wins." # Automatically win without strength-dependent reprompt.
	        break

	elif [[ $root_required != "root_required" || $USER == "root" ]]; then
	        if [[ $my_value == $beast_value || $my_value == "coffee" ]]; then
	                echo "You won!"
	        else
	                echo "You lose!"
	                exit 1
	        fi

	        (( attacks ++ ))
	        # echo "$attacks attacks so far. (debug)" # debug

	        if [[ $player_strength == "weak" && $attacks < 2 ]]; then # Check if user is weak. If yes, repro>
	                echo "You're weak; hit one more time. (Same number.)"
	                continue # if battle is incomplete, prompt for a new attack
	        fi
	else
	        echo "You lose! You're not \"root\"." # Don't reveal to player that "bernard" is the secret all-winning user.
	        exit 1
	fi

	# When battle is finished, quit while-loop
	break
done
}
#--- Function definitions END

echo "Welcome! Choose your player personality (1-3):
1 - Prophet	(easy)
2 - Layman	(medium)
3 - Evil person (harder) PS: Evil people don't get far."

# Player properties:
# player: 	prophet/layman/evil-person 	# used
# personality: 	joyful/neutral/grumbler 	# unused
# strength: 	strong/mediocre/weak		# used
# health: 	good/so-and-so/weak		# unused
# divine_help:	always/sometimes/rarely 	# used

read player_choice

case $player_choice in
	1)
		player="Prophet"
		personality="joyful"
		strength="mediocre"
		health="good"
		divine_help="always"
		;;

	2)
		player="Layman"
		personality="neutral"
		strength="mediocre"
		health="so-and-so"
		divine_help="sometimes"
		;;

	3)
		player="Evil person"
		personality="grumbler"
		strength="weak"
		health="weak"
		divine_help="rarely"
		;;
esac

echo ""
echo "Your player choices -----
Player: 		$player
personality (unused): 	$personality
strength: 		$strength
health (unused): 	$health
divine help: 		$divine_help
-------------------------"


# First beast battle (50/50 chance)
echo ""
echo "Your first beast approaches. Prepare to battle. Pick a number between 0-1! (0/1)"

beast_1_value=$(( $RANDOM % 2 ))
# echo "Beast value is $beast_1_value." #debug

# check if player gets divine help for this battle
divine_help $beast_1_value

# execute battle 1
# "coffee" is a cheat code to win the current attack
# "bernard" is a secret user to win the entire battle at once
battle $beast_1_value "root_not_required" $strength

sleep 1


# Second beast battle (1/10 chance)
echo ""
echo "Your second beast approaches. Prepare for battle. Pick a number between 0-9! (0-9)"

beast_2_value=$(( $RANDOM % 10 ))
# echo "Beast value is $beast_2_value." #debug

# check if player gets divine help for this battle
divine_help $beast_2_value

# Execute battle 2
# "coffee" is a cheat code to win the current attack
# "bernard" is a secret user to win the entire battle at once
# user automatically loses if player isn't logged in as "root" or "bernard"
battle $beast_2_value "root_required" $strength
