#!/bin/bash

MYDIR="/Users/eoincarley/data/elevate_db"
DIRS=`ls $MYDIR  | egrep '^2'`


# and now loop through the directories:
for DIR in $DIRS
do
	ACE_LOC=$MYDIR"/"${DIR}"/ACE/"
	ACE_FILE=`ls $ACE_LOC | egrep 'a*eps'`

	SOHO_LOC=$MYDIR"/"${DIR}"/SOHO/ERNE/"
	SOHO_FILE=`ls $SOHO_LOC | egrep 's*eps'`

	SDO_LOC=$MYDIR"/"${DIR}"/SDO/AIA/"
    SDO_FILE=`ls $SDO_LOC | egrep 'A*cool*'`
	
	convert -density 70 $ACE_LOC$ACE_FILE -flatten $ACE_LOC${ACE_FILE%.*}.png

	convert -density 70 $SOHO_LOC$SOHO_FILE -flatten $SOHO_LOC${SOHO_FILE%.*}.png

	if [ -n "$SDO_FILE" ]; then
		ffmpeg -i $SDO_LOC$SDO_FILE -vcodec libx264 -crf 24 $SDO_LOC${SDO_FILE%.*}.mp4
	fi	


done