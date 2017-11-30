#!/bin/bash

# kill all current conky sessions
killconky() {
  sudo killall --quiet conky
}
killconky

USERNAME=$( logname )
PRIMARY_CONFIG_FILE="/home/$USERNAME/.config/conky/conky-primary.conf"
SECONDARY_CONFIG_FILE="/home/$USERNAME/.config/conky/conky-secondary.conf"

SCREENS=0
X=0
Y=0
PRIMARY_X=0
GAP_X=15
GAP_Y=5
offset_y=0 # use to offset vertically due to monitor positioning and sizing
offset_x=0 # use to offset horizontally due to monitor positioning and sizing

while true; do
  _SCREENS=$( xrandr --listactivemonitors | grep Monitors | awk -F'[ ]' '{ print $2 }' )
  _PRIMARY_X=$( xrandr --current | grep \ connected | grep primary | awk -F+ '{print $2 }' )
  #_Y=$( xrandr --current | grep \ connected | grep primary | awk -F+ '{print $3 }' )
  if [ $SCREENS != $_SCREENS ] || [ $PRIMARY_X != $_PRIMARY_X ]; then
    SCREENS=$_SCREENS
    PRIMARY_X=$_PRIMARY_X
    killconky
    for MONITOR in `xrandr --listactivemonitors | grep -v Monitors | awk -F'[ ]' '{ print $3"_"$4 }' | sed 's/+//'`; do
      if [[ "$MONITOR" == *"*"* ]]; then
      
    # for wayland
    #for MONITOR in `xrandr --listactivemonitors | grep -v Monitors | awk -F'[ ]' '{ print $3"_"$4 }'`; do
    #  if [[ "$MONITOR" == 0* ]]; then

        CONFIG=$PRIMARY_CONFIG_FILE
      else
        CONFIG=$SECONDARY_CONFIG_FILE
      fi
      read -r X Y <<<$( echo $MONITOR | awk -F+ '{ print $2, $3 }' )
      echo "conky -x $(($GAP_X+$X+$offset_x)) -y $(($GAP_Y+$Y+$offset_y)) -c $CONFIG"
      conky -x $(($GAP_X+$X+$offset_x)) -y $(($GAP_Y+$Y+$offset_y)) -c $CONFIG &
    done
  fi
  sleep 10;
done
