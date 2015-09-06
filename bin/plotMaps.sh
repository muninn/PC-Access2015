#!/bin/sh
#
GMT gmtset GRID_PEN_PRIMARY 0.5p,grey,. 
GMT gmtset ANNOT_FONT_SIZE_PRIMARY 5 ANNOT_FONT_SIZE_SECONDARY 5
# Ticks then label
GMT gmtset HEADER_FONT_SIZE 3
GMT gmtset CHAR_ENCODING ISOLatin1
GMT gmtset HEADER_OFFSET 0.075c
#ssh -i ~/.ssh/trenchfoot rhwarren@trenchfoot.cs.uwaterloo.ca "grep -E -i 'feel great|feel awesome|feel good|healthy' Store2/SMILE2013/flu.tweets Store2/SMILE2013/oldflu.tweets | cut -f 5,6" | awk '{print $2,$1}' > good.xy
#ssh -i ~/.ssh/trenchfoot rhwarren@trenchfoot.cs.uwaterloo.ca "grep -E -i 'sneeze|runny nose|fever|flu|sick' Store2/SMILE2013/flu.tweets Store2/SMILE2013/oldflu.tweets | cut -f 5,6" | awk '{print $2,$1}' > sick.xy 
#ssh -i ~/.ssh/trenchfoot rhwarren@trenchfoot.cs.uwaterloo.ca "grep -E -i 'feel great|feel awesome|feel good|healthy' Store2/SMILE2013/flu.tweets  | cut -f 5,6" | awk '{print $2,$1}' > good.xy
#ssh -i ~/.ssh/trenchfoot rhwarren@trenchfoot.cs.uwaterloo.ca "grep -E -i 'sneeze|runny nose|fever|flu|sick' Store2/SMILE2013/flu.tweets  | cut -f 5,6" | awk '{print $2,$1}' > sick.xy 
#47.33138 
#LAKES=" -I1/0/0/255 -I3/0/0/255 -S0/0/200 "
LAKES=" -Ia"
#GMT gmtset MAP_GRID_CROSS_SIZE_PRIMARY 0.1i MAP_FRAME_TYPE FANCY FORMAT_GEO_MAP ddd:mm:ssF
#GMT psbasemap -J${PROJECTION} -R${RANGE} -B1g0.5/0.3g0.3  -X1 -Y1 -P -K -V  > figures/world.ps
#GMT pscoast   -J${PROJECTION}d -R${RANGE}  -B1g0.5/0.3g0.3 -BWSen  -Glightbrown -Wthinnest -K -O -V -G0 -Dc -P -Slightblue >> figures/world.ps
#GMT pscoast -Rg-55/305/-90/90 -I1.8/1.8 -B1g0.5/0.3g0.3k -BWSen -Dc -A1000 -Glightbrown -Wthinnest -P -Slightblue > figures/world.ps
LEFT=-142.230470
RIGHT=-57.503906
TOP=61
BOTTOM=43.038892
RANGE="${LEFT}/${RIGHT}/${BOTTOM}/${TOP}"
WIDTH="500"
PD=`echo "scale=6;${WIDTH} / (${RIGHT} - ${LEFT})" | bc`
PROJECTION="M${PD}i"
echo "Projection is ${PROJECTION}."
#wget -N -O halifax.svg "http://render.openstreetmap.org/cgi-bin/export?bbox=${LEFT},${BOTTOM},${RIGHT},${TOP}&scale=98470&format=svg" --user-agent="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-us) AppleWebKit/531.22.7 (KHTML, like Gecko) Version/4.0.5 Safari/531.22.7"
#
#cairosvg-2.7 halifax.svg --dpi=1200 -f ps -o out.ps
#rm out.eps
#ps2eps --resolution 1200 out.ps
GMT pscoast -R${RANGE} -J${PROJECTION} -B5g10 -W1/0 -G240 -K -Df -P ${LAKES} -Na > figures/canada.ps
#GMT psimage out.eps -J${PROJECTION} -E211 -O -K >> figures/canada.ps
#
# Yes, this is the wrong way to do it....
IWIDTH=14.16
IHEIGHT=5.16
cp figures/canada.ps figures/canada_images.ps
#
for line in `find . -type f -name "*-location.rdf" -exec cat {} \; | cut -d "\"" -f 2 | rev | cut -d "/" -f 2 | rev | tr " " "\n" | sort -u`
do
# echo "[ ${line} ]"
 if [ ! -f "geonames/${line}.rdf" ]
 then
  curl -H "Accept: application/rdf+xml" -L "http://sws.geonames.org/${line}/" > geonames/${line}.rdf
 fi
 THISLOC=`cat geonames/${line}.rdf | grep -E "wgs84_pos:lat|wgs84_pos:long" | tr "<" "\n" | tr ">" "\n" | grep "\." | tr "\n" " " | rev | cut -c 2- | rev`
 echo ${THISLOC} | GMT psxy  -R${RANGE} -J${PROJECTION} -: -O -P -Sc3p  -Gred  -K  -V -L >>  figures/canada.ps  
 THISY=`echo ${THISLOC} | cut -d " " -f 1`
 THISX=`echo ${THISLOC} | cut -d " " -f 2`
 NEWX=`echo "scale=5;(${THISY} - ${BOTTOM})/(${TOP} - ${BOTTOM})*${IHEIGHT}" | bc`
 NEWY=`echo "scale=5;(${THISX} - ${LEFT})/(${RIGHT} - ${LEFT})*${IWIDTH}" | bc` 
 #echo "scale=5;(${THISY} - ${BOTTOM})/(${TOP} - ${BOTTOM})*${IHEIGHT}"
 #echo "scale=5;(${THISX} - ${LEFT})/(${RIGHT} - ${LEFT})*${IWIDTH}"
 #echo "${THISX}/${THISY}  ${NEWX}/${NEWY}"
 GMT psimage pc.eps -J${PROJECTION} -E100 -W1/1 -C${NEWY}c/${NEWX}c -O -K >> figures/canada_images.ps 
done
#GMT psimage pc.eps -J${PROJECTION} -E300 -W10/10 -C-100/50 -O -K >> figures/canada_images.ps
#GMT psimage pc.eps -J${PROJECTION} -E300 -W10/10 -C50/-100 -O -K >> figures/canada_images.ps
#GMT psimage pc.eps -J${PROJECTION} -E100 -W1/1  -O -K >> figures/canada_images.ps
GMT psimage pc.eps -J${PROJECTION} -E100 -W1/1 -C1/3 -O -K >> figures/canada_images.ps
#echo  "2.811238 50.373733 5 0 9 6  
#GMT psxy  -R${RANGE} -J${PROJECTION}  -O -P   -K  -V -L  >> figures/coffeeHalifaxOtherFSA.ps
#GMT psxy  -R${RANGE} -J${PROJECTION}  -O -P   -K  -V -L  < mpoly.gmt >> figures/coffeeHalifaxOtherFSA.ps
echo  | GMT psxy  -R${RANGE} -J${PROJECTION}  -O -P -Sc3p  -Gred -V -L   >> figures/canada.ps 
echo  | GMT psxy  -R${RANGE} -J${PROJECTION}  -O -P -Sc3p  -Gred -V -L   >> figures/canada_images.ps 
GMT ps2raster figures/canada.ps  -A -Tf
GMT ps2raster figures/canada_images.ps  -A -Tf
#
