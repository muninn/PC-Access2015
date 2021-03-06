#!/opt/local/bin/gnuplot
stats 'postcardColour.dat' u 2 
sum = STATS_sum
R = 1
set xrange [-R:R]
set yrange [-R:R]
set size ratio -1
unset key
unset border
unset tics
set style fill solid 0.6
set term pngcairo enh font "Times,10" size 480,480
set out "figures/postcardColour.png"
set title "Postcard Colours" font "Helvetica,18"
cum = 0
k = 0
ac = 0
ap = 0
ag = 0
LR = 0.7
plot 'postcardColour.dat' u (cum=cum+$2, k=k+1, 0):(0):(R): \
                     ((cum-$2)/sum*360):(cum/sum*360):(k) \
                   w circle lw 0.1 lc variable, \
'' u (ap=ac, ac=ac+$2, ag=(ac+ap)/sum*pi, LR*R*cos(ag)):\
   (LR*R*sin(ag)):1 w labels tc rgb "gray20" font "Times,16"
