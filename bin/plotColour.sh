#!/bin/sh
#
find . -name "*.xml" -exec grep "<extent>" {} \; | cut -d ">" -f 2 | tr " " "\n" | tr "[:punct:]" " " | grep -E -i "b |col|sepia" | sed -e 's/^[ \t]*//;s/[ \t]*$//' |  sort | uniq -c | sed 's/b amp w/Black and White/g' | sed 's/col/Colour/g' | sed 's/sepia/Sepia/g' | awk 'BEGIN{ FS=" " } {print $2 " " $1}' > postcardColour.dat

