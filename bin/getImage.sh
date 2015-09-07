#!/bin/sh
#
URL=`grep 'url access="raw object"' $1 | rev | cut -d "<" -f 2 | cut -d ">" -f 1 | rev`
if [ ! -z "${URL}" ]
then
 curl "${URL}" | convert - -resize '10%' > $2
fi