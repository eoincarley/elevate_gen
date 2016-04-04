#!/bin/bash

MYDIR="/Users/eoincarley/data/elevate_db"
MIRROR_DIR="/Users/eoincarley/ELEVATE/website/maths_server_mirror"
DIRS=`ls $MYDIR  | egrep '^2'`
cd $MIRROR_DIR

for DIR in $DIRS
do
    ACE_MIRR_DIR=$MIRROR_DIR"/"${DIR}"/ACE/"
    SOHO_MIRR_DIR=$MIRROR_DIR"/"${DIR}"/SOHO/"
    SDO_MIRR_DIR=$MIRROR_DIR"/"${DIR}"/SDO/"

    #mkdir -p $ACE_MIRR_DIR
    #mkdir -p $SOHO_MIRR_DIR
    #mkdir -p $SDO_MIRR_DIR

    #ACE_LOC=$MYDIR"/"${DIR}"/ACE/"
    #ACE_FILE=`ls $ACE_LOC | egrep 'a*png'`
       
    #SOHO_LOC=$MYDIR"/"${DIR}"/SOHO/ERNE/"
    #SOHO_FILE=`ls $SOHO_LOC | egrep 's*png'`

    #SDO_LOC=$MYDIR"/"${DIR}"/SDO/AIA/"
    #SDO_FILE=`ls $SDO_LOC | egrep "mp"`

    PARAM_FILE_LOC=$MYDIR"/"${DIR}"/"
    PARAM_FILE1=`ls $PARAM_FILE_LOC | egrep '2*txt'`
    PARAM_FILE2=`ls $PARAM_FILE_LOC | egrep '2*sav'`

    #echo Moving $ACE_FILE to $ACE_MIRR_DIR
    #cp $ACE_LOC"/"$ACE_FILE $ACE_MIRR_DIR  

    #echo Moving $SOHO_FILE to $SOHO_MIRR_DIR
    #cp $SOHO_LOC"/"$SOHO_FILE $SOHO_MIRR_DIR

    #if [ -n "$SDO_FILE" ]; then
    #    echo Moving $SDO_FILE #to $SDO_MIRR_DIR
    #    mv $SDO_LOC"/"$SDO_FILE $SDO_MIRR_DIR  
    #fi    
    

    echo Moving $PARAM_FILE1 to $MIRROR_DIR"/"${DIR}"/"
    cp $MYDIR"/"${DIR}"/"$PARAM_FILE1 $MIRROR_DIR"/"${DIR}"/"

    echo Moving $PARAM_FILE2 to $MIRROR_DIR"/"${DIR}"/"
    cp $MYDIR"/"${DIR}"/"$PARAM_FILE2 $MIRROR_DIR"/"${DIR}"/"
    echo ----



done

