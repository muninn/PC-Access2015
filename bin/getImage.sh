#!/bin/sh
#
# This is going to take the first image available as a thumb.
URL=`grep 'url access="raw object"' $1 | rev | cut -d "<" -f 2 | cut -d ">" -f 1 | rev | head -n 1 | cut -d " " -f 1`
echo ${URL}
if [ ! -z "${URL}" ]
then
 echo "$2 ${URL}"
 curl "${URL}" | convert - -resize "10%"  $2
fi