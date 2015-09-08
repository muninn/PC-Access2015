#!/bin/sh
IN=$1
OUTF=$2
NUMBER=`xpath $1 '/mods/subject/hierarchicalGeographic' | grep "<hierarchicalGeographic>" | wc -l`
for THIS_LOC in `seq 1 ${NUMBER}`
do
 GEOBLURB=`xpath $1 "/mods/subject/hierarchicalGeographic[${THIS_LOC}]"`
 echo ${GEOBLURB}
done
exit 0
PLACE=`grep geographic $1 | cut -d ">" -f 2 | cut -d "<" -f 1 | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/Calgary, MB/Calgary, AB/g'`
echo "["${PLACE}"]"
if [ -z "${PLACE}" ]
then
 echo   > ${OUTF}
 exit 0
fi
PROV=`echo ${PLACE} | cut -d ","  -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//'`
OTHER=`echo ${PLACE} | cut -d ","  -f 1 | sed 's/^[ \t]*//;s/[ \t]*$//' | tr " " "+"`
KEY=`echo ${PLACE} | shasum | cut -d " " -f 1`
echo ${KEY}
echo ${PROV}
echo ${OTHER}
if [ "${PROV}" == "AB" ]
then
 PROV="Alberta"
elif [ "${PROV}" == "MB" ]
then
 PROV="Manitoba"
elif [ "${PROV}" == "ON" ]
then
 PROV="Ontario"
elif [ "${PROV}" == "SK" ]
then
 PROV="Saskatchewan"
elif [ "${PROV}" == "BC" ]
then
 PROV="British Columbia"
else
 echo "Unknown province ${PROV}."
 PROV="Unknown"
 exit 0
fi
MYANSWER=""
MYANSWER=`grep ${KEY} cache | cut -d "," -f 2- | cut -c 2-`
if [ -z "${MYANSWER}" ]
then
 sleep 4
 HITS=`curl "http://api.geonames.org/search?country=CA&type=rdf&username=API_KEY&name_equals=${OTHER}&featureClass=P&style=full" | grep "gn:Feature" | tr "/" "\n" | grep '[0-9]' | sed 's/^[ \t]*//;s/[ \t]*$//'`
 for HIT in `echo ${HITS}`
 do
  echo "Checking place # ${HIT}."
  sleep 2
  if [ `curl "http://api.geonames.org/hierarchy?geonameId=${HIT}&username=API_KEY" | xpath "/geonames/geoname[name='${PROV}' and fcode='ADM1']" | wc -l` -gt 0 ]
  then
   echo "Good hit on ${HIT}."
   MYANSWER="${HIT}"
   break
  fi
 done  
 if [ ! -z "${MYANSWER}" ]
 then
   echo "${KEY}, ${MYANSWER}" >> cache
 fi
fi
#
# Try with Fuzzy match
#
if [ -z "${MYANSWER}" ]
then
 sleep 4
 HITS=`curl "http://api.geonames.org/search?country=CA&type=rdf&username=API_KEY&q=${OTHER}&featureClass=P&style=full" | grep "gn:Feature" | tr "/" "\n" | grep '[0-9]' | sed 's/^[ \t]*//;s/[ \t]*$//'`
 for HIT in `echo ${HITS}`
 do
  echo "Checking place # ${HIT}."
  sleep 2
  if [ `curl "http://api.geonames.org/hierarchy?geonameId=${HIT}&username=API_KEY" | xpath "/geonames/geoname[name='${PROV}' and fcode='ADM1']" | wc -l` -gt 0 ]
  then
   echo "Good hit on ${HIT}."
   MYANSWER="${HIT}"
   break
  fi
 done  
 if [ ! -z "${MYANSWER}" ]
 then
   echo "${KEY}, ${MYANSWER}" >> cache
 fi
fi
#
# Try with any feature
#
if [ -z "${MYANSWER}" ]
then
 sleep 4
 HITS=`curl "http://api.geonames.org/search?country=CA&type=rdf&username=API_KEY&q=${OTHER}&style=full" | grep "gn:Feature" | tr "/" "\n" | grep '[0-9]' | sed 's/^[ \t]*//;s/[ \t]*$//'`
 for HIT in `echo ${HITS}`
 do
  echo "Checking place # ${HIT}."
  sleep 2
  if [ `curl "http://api.geonames.org/hierarchy?geonameId=${HIT}&username=API_KEY" | xpath "/geonames/geoname[name='${PROV}' and fcode='ADM1']" | wc -l` -gt 0 ]
  then
   echo "Good hit on ${HIT}."
   MYANSWER="${HIT}"
   break
  fi
 done  
 if [ ! -z "${MYANSWER}" ]
 then
   echo "${KEY}, ${MYANSWER}" >> cache
 fi
fi
echo "${MYANSWER}" 
if [ ! -z "${MYANSWER}" ]
then
 echo "<foaf:depicts rdf:resource=\"http://sws.geonames.org/"${MYANSWER}"/\"/>" > ${OUTF}
else
 echo ${IN} >> missing
fi

