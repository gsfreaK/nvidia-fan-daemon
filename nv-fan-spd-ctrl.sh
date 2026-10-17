#!/bin/bash
fsMin=30
fsMax=100
tMin=30
tMax=75
xtrafSpd=6
pwrLmt=$(nvidia-smi --query-gpu=power.max_limit --format=csv | awk 'NR==2 {printf "%d\n", $1 / 2}')            # Queries the max power limit and divides it by 2
setFanSpeed() { sudo nvidia-settings -c :0  -a GPUFanControlState="$1" -a GPUTargetFanSpeed="$fanSpd" > /dev/null; }		# Sets the control state to manual and set the disred fan speed	
cleanup() { sudo nvidia-settings -c :0 -a GPUFanControlState=0 -a GPUPowerMizerMode=0; }		#Restores original config
trap cleanup 1 2 3 15 20		# Run cleanup() on exit signals (1,2,3,15,20)
while true; do
gpuTemp=$(nvidia-settings -c :0 -t -q gpucoretemp)		# Get current GPU temperature
if [ $gpuTemp -le $tMin ]; then setFanSpeed 0 0; elif [ $gpuTemp -ge $tMax ]; then sudo nvidia-smi -pl $pwrLmt -gtt 69; sudo nvidia-settings -c :0 -a GPUTargetFanSpeed="100"; else fanSpd=$(((($gpuTemp - $tMin)*($fsMax - $fsMin) / ($tMax - $tMin) + $fsMin) + $xtrafSpd ))		  # Check temperature range and adjust fan or power limits (to half the max TDP of the card)
fi
setFanSpeed 1 $fanSpd		#Sets the calculated fan speed
sleep 3		# Pauses the app for 3 seconds
done
