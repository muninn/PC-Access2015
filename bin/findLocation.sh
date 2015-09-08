#!/bin/sh
for THIS_LOC in `tr " " "+" < $1`
do
 COUNTRY=`echo ${THIS_LOC} | tr "+" " " | xpath  "/hierarchicalGeographic/country/text()"`
 REGION=`echo ${THIS_LOC} | tr "+" " " | xpath  "/hierarchicalGeographic/province/text()|/hierarchicalGeographic/state/text()"`
 CITY=`echo ${THIS_LOC} | tr "+" " " | xpath  "/hierarchicalGeographic/city/text()" | sed 's/^[ \t]*//;s/[ \t]*$//' | tr " " "+"`
if [ "${COUNTRY}" == "Canada" ]
then
 COUNTRY="CA"
elif [ "${COUNTRY}" == "United States" ]
then
 COUNTRY="US"
fi
 echo ${COUNTRY} ${REGION} ${CITY}
if [ ! -z "${CITY}" ] && [ -z "`echo ${CITY} | grep ','`" ]
then
URL=`curl "http://api.geonames.org/search?country=${COUNTRY}&type=rdf&username=API_KEY&name_equals=${CITY}&featureClass=P&style=full" | xpath "/rdf:RDF/gn:Feature/@rdf:about" | cut -d "\"" -f 2`
echo "${THIS_LOC}\t${URL}"
#| xpath "/rdf:RDF/gn:Feature@rdf:about"
elif [ ! -z "${CITY}" ] && [ ! -z "`echo ${CITY} | grep ','`" ]
 CITY=`echo ${CITY} | rev | cut -d "," -f 2- | rev |  sed 's/^[ \t]*//;s/[ \t]*$//'`
 URL=`curl "http://api.geonames.org/search?country=${COUNTRY}&type=rdf&username=API_KEY&name_equals=${CITY}&featureClass=P&style=full" | xpath "/rdf:RDF/gn:Feature/@rdf:about" | cut -d "\"" -f 2`
 echo "${THIS_LOC}\t${URL}"
 #echo ${THIS_LOC}
fi
sleep 3
done
#
#
exit 0
