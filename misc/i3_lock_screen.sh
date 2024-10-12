img=/tmp/i3lock.png

scrot -o $img

pkill -u "$USER -x picom"

convert $img -scale 10% -scale 1000% $img

i3lock -u -i $img

picom --config ~/.config/picom/picom.conf &
