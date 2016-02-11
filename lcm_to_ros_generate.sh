#!/bin/bash

mkdir -p msg autosrc launch

echo "" > autosrc/CMakeLists.txt
LAUNCH_FILE="launch/all_republishers.launch"

LCM_TYPES=(int8_t int16_t int32_t int64_t float   double  string boolean byte)
ROS_TYPES=(int8   int16   int32   int64   float32 float64 string bool byte)

N_TYPES=${#LCM_TYPES[@]}

echo  "<launch>" > $LAUNCH_FILE
echo -e "\t<master auto=\"start\" />" >> $LAUNCH_FILE
echo -e "\t<group ns=\"lcm_to_ros\">" >>  $LAUNCH_FILE

for INFILE in lcm/*.lcm
do
    MESSAGE_NAME=$( echo $INFILE | sed 's:lcm/::; s/.lcm//')
    
    echo "Processing LCM message file: $MESSAGE_NAME"
    echo -n -e "\tCreating LCM CPP message header exlcm/$MESSAGE_NAME.hpp ..."
    # Create lcm CPP header (in exlcm subfolder)
    lcm-gen -x $INFILE
    echo " done."
    
    # Create corresponding ros message
    OUTFILE="msg/$MESSAGE_NAME.msg"
    echo -n -e "\tCreating ROS message $OUTFILE..."
    echo $(printf '#%.0s' {1..71}) > $OUTFILE
    echo "# This message was automatically generated by the lcm_to_ros package" >>$OUTFILE
    echo "# https://github.com/nrjl/lcm_to_ros, nicholas.lawrance@oregonstate.edu" >>$OUTFILE
    echo -e "$(printf '#%.0s' {1..71})\n#" >>$OUTFILE
    echo "# Source message:    $MESSAGE_NAME.msg" >> $OUTFILE
    echo "# Creation:          $(date '+%c')" >> $OUTFILE
    echo -e "#\n$(printf '#%.0s' {1..71})" >>$OUTFILE
    # sed finds lines in braces {}, removes top and tail lines, leading whitespace and semicolons
    cat $INFILE | sed '/{/,/}/!d' | sed '1d; $d; s/^[ \t]*//; s/;//; ' > tmp
    # Convert datatypes
    for (( i=0; i<${N_TYPES}; i++ ))
    do
        sed -i "s/${LCM_TYPES[$i]}/${ROS_TYPES[$i]}/" tmp
    done
    # awk to extract array indices (if present)
    cat tmp | awk -F"[][ \t]"+ '{ if (NF == 2) x=$1; else x = $1"["$3"]"; printf "%-20s%s\n", x, $2}' >>$OUTFILE    
    rm tmp
    echo " done."
    
    OUTFILE="autosrc/${MESSAGE_NAME}_republisher.cpp"
    echo -n -e "\tCreating CPP file $OUTFILE..."
    cat src/default_republisher.cpp.in | sed "s/@MESSAGE_TYPE@/$MESSAGE_NAME/g" > $OUTFILE
    echo " done."
    
    echo -n -e "\tAdding entry to autosrc/CMakeLists.txt ..."
    cat src/default_CMakeLists.txt.in | sed "s/@MESSAGE_TYPE@/$MESSAGE_NAME/g" >> autosrc/CMakeLists.txt
    echo " done."
    
    echo -n -e "\tAdding entry to $LAUNCH_FILE ..."
    echo -e "\t\t<node pkg=\"lcm_to_ros\" type=\"${MESSAGE_NAME}_republisher\" respawn=\"false\" name=\"${MESSAGE_NAME}_republisher\" output=\"screen\"/>" >> $LAUNCH_FILE
    echo " done."
done

echo -e "\t</group>" >>  $LAUNCH_FILE
echo "</launch>" >> $LAUNCH_FILE
