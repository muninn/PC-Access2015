LIBS=$(shell find 0* -name "*.xml" -type f |rev | sort | rev)
OUTPUT := $(LIBS:.xml=-location.rdf)
SUBJECT:= $(LIBS:.xml=-subjects.rdf)
THUMB:= $(LIBS:.xml=-thumbs.jpg)
THUMBDL:= $(shell find 0* -name "*-thumbs.jpg" -type f |rev | sort | rev)
THUMBEPS:= $(THUMBDL:-thumbs.jpg=-thumbs.eps)
talk.pdf: talk.tex 
	pdflatex talk
talk: talk.pdf
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -sOutputFile=talk-compressed.pdf talk.pdf
alltopics.asc:
	find . -name "*.xml" -exec xpath {} "/mods/subject/topic" \; 2> /dev/null | tr "<" "\n" | tr ">" "\n" | grep -v -E "^topic$$"  | grep -v -E "^\/topic" | sort -u | grep -v -e '^$$' > alltopics.asc	
#	 grep -v -E "^topic$"  | grep -v -E "^/topic$"  | sed 's/\&amp;/\&/g'| tr " " "+" > alltopics.asc
allLoctopics.asc:
	rapper subjects-skos-20140306.rdf | grep "prefLabel" | cut -d " " -f 1,3-  | tr "<" " " | grep -v -e '^$$' > allLoctopics.asc
#	xpath $< "/mods/subject/topic" \; 2> /dev/null | tr "<" "\n" | tr ">" "\n" | grep -v -E "^topic$"  | grep -v -E "^/topic$"  | sed 's/\&amp;/\&/g'| tr " " "+" > alltopics.asc
#	
mergedTopics.asc:	alltopics.asc allLoctopics.asc
	./bin/mergeLOCSubjects.pl alltopics.asc allLoctopics.asc > mergedTopics.asc
%-subjects.rdf:		%.xml  mergedTopics.asc findSubjectHit.sh
	./bin/findSubjectHit.sh $< mergedTopics.asc  > $@
#%-location.rdf :	%.xml scrapeLocation.sh
#	echo "Going from $< to $@"
#	./scrapeLocation.sh $< $@
%-thumbs.jpg: %.xml
	bin/getImage.sh $< $@
%-thumbs.eps: %-thumbs.jpg
	convert $< $@	
postcardColour.dat:
	./bin/plotColour.sh
figures/postcardColour.png: postcardColour.dat
	./bin/plotColour2.gnuplot	
allLocations.asc: dud
	find . -name "*.xml" -exec ./scrapeLocation.sh {} \;  | sed 's/<hie/\\'$\'\n<hir/g' |sort -u > allLocations.asc
BadLocations.asc:  allLocations.asc
	grep "?" allLocations.asc > BadLocations.asc
GoodLocations.asc: allLocations.asc
	grep -v "?" allLocations.asc > GoodLocations.asc
MatchedLocations.asc: GoodLocations.asc 
	./bin/findLocation.sh GoodLocations.asc > MatchedLocations.asc
#all:  $(OUTPUT) alltopics.asc allLoctopics.asc mergedTopics.asc $(SUBJECT)
all: $(THUMBEPS)



	