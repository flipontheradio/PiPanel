#!/bin/bash

#max brightness variable can not exceed 200
MAXBRIGHTNESS=200
MINBRIGHTNESS=20
LIGHTVALUE=$(sudo ./YLightSensor any get_currentValue)

if [ "$LIGHTVALUE" = "ERR: No module found" ]; then
  echo $LIGHTVALUE
  echo "200" > /home/pi/Documents/maxBrightness.txt
  exit 0
fi


while true; do

  sleep 1

  LIGHTVALUE="$(($(sudo /home/pi/Documents/./YLightSensor any get_currentValue | sed 's/.*= //' | sed 's/\..*$//' ) * 3))"
  #echo $LIGHTVALUE
  #echo "$(($LIGHTVALUE * 2))"

  if [ $LIGHTVALUE -gt $MAXBRIGHTNESS ]; then
    #echo "Greater than"
    echo "200" > /home/pi/Documents/maxBrightness.txt
  elif [ $LIGHTVALUE -lt $MINBRIGHTNESS ]; then
    #echo "Less than"
    echo "20" > /home/pi/Documents/maxBrightness.txt
  else
    #echo "Middle Ground"
    echo "$LIGHTVALUE" > /home/pi/Documents/maxBrightness.txt
  fi

done

exit 0
