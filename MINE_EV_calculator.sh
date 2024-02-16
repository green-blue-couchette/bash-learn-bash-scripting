#!/bin/bash

# Author: O.A.

# ABOUT: CALCULATE THE EXPOSURE VALUE (EV) FOR YOUR CAMERA SETTINGS. (Does not take into account the film roll's reciprocity behavior for long exposures.)
# FORMULA: EV = Log_base2(100 * aperture² / ISO * shutter speed )

# final code
echo "Calculate EV for your chosen camera settings"
echo "Formula: EV = Log_base2(100 * aperture² / ISO * shutter speed )"
echo ""

echo "Enter Aperture (F-STOP):"
read aperture

echo "Enter film's ISO:"
read ISO

echo "Enter shutter speed (s):"
read shutter_speed

# dummy values
# aperture=11
# ISO=400
# shutter_speed=0,01

aperture_over_exposure_time=$( echo "scale=4; ((100 * $aperture * $aperture)/($ISO * $shutter_speed))" | bc -l ) # the calculation that we will calculate the logarithm for
EV=$(echo "l($aperture_over_exposure_time)/l(2)" | bc -l) # calculates the logarithm

echo "EV = $EV"
