#!/bin/bash
gawk  '{
	if($0!~/#/) {
		i++
 		label[i] = $1
 		v[i] = $2
 		D+= $2
	}
	}
	END {
		print "reset"
		print "b=0.4; a=0.2; B=0.5"
		print "set view 30, 20; set parametric"
		print "unset border; unset tics; unset key; unset colorbox"
		print "set ticslevel 0"
		print "set urange [0:1]; set vrange [0:1]"
		print "set xrange [-2:2]; set yrange [-2:2]; set zrange [0:3]"
		print "set multiplot"
		print "set palette model RGB functions 0.9, 0.9,0.95"
		print "splot -2+4*u, -2+4*v, 0 w pm3d"
		print "set palette model RGB functions 0.8, 0.8, 0.85"
		printf "set urange [%g:1]\n", v[0]/D
		print "splot cos(u*2*pi)*v, sin(u*2*pi)*v, 0 w pm3d"
		printf "set urange [0:%g]\n", v[0]/D
		printf "splot cos(%g*pi)*b+cos(u*2*pi)*v, sin(%g*pi)*b+sin(u*2*pi)*v, 0 w pm3d\n", v[0]/D, v[0]/D
		print "set palette model RGB functions 1, 0, 0"
		printf "set urange [0:%g]\n", v[0]/D
		printf "splot cos(%g*pi)*b+cos(u*2*pi)*v, sin(%g*pi)*b+sin(u*2*pi)*v, a w pm3d\n", v[0]/D, v[0]/D, d=v[0]/D
		for(j=1;j<i;j++) {
			printf "set palette model RGB functions %g, %g, %g\n", (j%3+1)/3, (j%6+1)/6, (j%9+1)/9
			printf "set urange [%g:%g]\n", d, d+v[j]/D
			print "splot cos(u*2*pi)*v, sin(u*2*pi)*v, a w pm3d"
			d+=v[j]/D
		}
		d=v[1]/D
		for(j=1;j<i;j++) {
			printf "set label %d \"s\" at cos(%g*pi)*B+cos(%g*pi), sin(%g*pi)*B+sin(%g*pi)\n", j+1, label[j], d, d, d, d
d=d+v[j]/D+v[j+1]/D
		}
		printf "set label %d \"s\" at cos(%g*pi)*B+cos(%g*pi), sin(%g*pi)*B+sin(%g*pi)\n", i, label[i-1], d, d, d, d
		printf "set palette model RGB functions %f, %f, %f\n", (i%3+1)/3, (i%6+1)/6, (i%9+1)/9
		printf "set urange [%g:1]\n", 1.0-v[i-1]/D
		print "splot cos(u*2*pi)*v, sin(u*2*pi)*v, a w pm3d"
		print "unset multiplot"
}' $1
