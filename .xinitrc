xrandr --output HDMI-0 --auto --output DVI-0 --auto --left-of HDMI-0 --output VGA-0 --right-of HDMI-0

while true;
do
  awsetbg -r .config/awesome/backgrounds
  sleep 15m
done &

setxkbmap es -option caps:escape

exec awesome
