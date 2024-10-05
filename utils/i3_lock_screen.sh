img=/tmp/i3lock.png

scrot -o $img
convert $img -scale 7.5% -scale 1500% $img

i3lock -u -i $img

