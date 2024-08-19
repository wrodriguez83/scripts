RESOLUTION="3440 1440 60" 
OUTPUT="HDMI-1"

CONNECTED=$(xrandr --current | grep -i $OUTPUT | cut -f2 -d' ')

MODELINE=$(cvt $RESOLUTION | cut -f2 -d$'\n')
MODEDATA=$(echo $MODELINE | cut -f 3- -d' ')
MODENAME=$(echo $MODELINE | cut -f2 -d' ')

echo "Adding mode - " $MODENAME $MODEDATA
xrandr --newmode $MODENAME $MODEDATA
xrandr --addmode $OUTPUT $MODENAME

if [ "$CONNECTED" = "connected" ]; then
    xrandr --output $OUTPUT --mode $MODENAME
else
    echo "Monitor is not detected"
fi
