#!/bin/bash

echo "program start"

#n seconds until screen dims after last touch
TIME_TODIM=30

#n seconds until screen switches backt to photo album after last touch, must be greater than TIME_TODIM
TIME_TOOFF=45

#n seconds that the loop runs
INTERVAL=.1

#homepage of main actions tiles panel you want to default to after TIME_TOOFF
HOMEPAGE=<homepage here>

TOUCH_STATUS=true

sleep 20

#set inintial touch status
STATE1=$(</home/pi/Documents/cursorXPos.txt)
CONTROLPANEL=true

#start main loop 
while true; do
  sudo sh -c 'echo '"$(</home/pi/Documents/maxBrightness.txt)"' > /sys/class/backlight/rpi_backlight/brightness'

  #grab touch postion
  STATE2=$(</home/pi/Documents/cursorXPos.txt)

  #if touched changed state, enable touch on display, switch to action tiles tab
  if [ $STATE1 != $STATE2 ]; then
    if [ "$CONTROLPANEL" = false ]; then
    	xdotool key Control_L+2
    fi
    xinput enable "FT5406 memory based driver"
    TOUCH_STATUS=true
    STATE1=$STATE2
    SECONDS=0
  fi

  #check if the backlight should be on
  bash /home/pi/Documents/backlightStatus.txt

  #start touch countdown
  while $TOUCH_STATUS; do

    #check if new touch during touch countdown
    STATE2=$(</home/pi/Documents/cursorXPos.txt)

    #make sure th backlight is one during touch countdown
    sudo sh -c "echo 0 > /sys/class/backlight/rpi_backlight/bl_power"

    #dim if no touch detected after n seconds and disable touch on display 
    if [ $SECONDS -gt $TIME_TODIM ]; then
      CONTROLPANEL=false
      xinput disable "FT5406 memory based driver"
      sudo sh -c 'echo "10" > /sys/class/backlight/rpi_backlight/brightness'
    fi

    #switch to photo album if no touch after n seconds, enable touch display, reset action tiles homepage
    if [ $SECONDS -gt $TIME_TOOFF ]; then
      sudo sh -c 'echo "0" > /sys/class/backlight/rpi_backlight/brightness'
      xinput disable "FT5406 memory based driver"
      xdotool key Control_L+w
      chromium-browser --kiosk --noerrdialogs "$HOMEPAGE" --incognito --disable-translate
      xdotool key Control_L+1
      xinput enable "FT5406 memory based driver"
      sleep .3

      #fade in after switch to photo album
      for i in `seq 0 10 $(</home/pi/Documents/maxBrightness.txt)`; do
        sudo sh -c 'echo '"$i"' > /sys/class/backlight/rpi_backlight/brightness'
      done
      TOUCH_STATUS=false
    fi

    #check if new touch has been detected during touch countdown, reset countdown, renable touch display reset screen brightness
    if [ $STATE1 != $STATE2 ]; then
      if [ "$CONTROLPANEL" = false ]; then
      	xdotool key Control_L+2
      fi
      CONTROLPANEL=true
      xinput enable "FT5406 memory based driver"
      sudo sh -c 'echo '"$(</home/pi/Documents/maxBrightness.txt)"' > /sys/class/backlight/rpi_backlight/brightness'
      STATE1=$STATE2
      SECONDS=0
      TOUCH_STATUS=true
    fi
    sleep $INTERVAL
  done
  sleep $INTERVAL
done

exit 0
