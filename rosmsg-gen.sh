#!/usr/bin/env bash

print_help() {
    if [ $# -gt 0 ] ; then
        echo -e "ERROR: $*\n"
    fi
    echo "Usage: $0 [options] inputlcm"
    echo "Generate CPP and ROS message definitions from lcm messages".
    echo "Options:"
    echo "  -a      Use all files in lcm/*.lcm"
    echo "  -h      Print this help and exit"
    echo -e "\nSample usage:"
    echo " $0 -a"
    echo "     Generate CPP and ROS message defs, for each file lcm/*.lcm"
    exit 2
}

FULLDIR=false

while getopts ':ah' flag; do
  case "${flag}" in
    a) FULLDIR=true
       echo " * Using all files in lcm/*.lcm" >&2 ;;
    h) print_help ;;
    \?) print_help "Invalid option: -$OPTARG" ;;
  esac
done

shift $((OPTIND-1))

if [ $# -eq 0 ] && [ "$FULLDIR" = false ] ; then
    print_help "Must specify either input files or -a"
fi

if [ "$FULLDIR" = true ] ; then
    INFILES=lcm/*.lcm
else
    INFILES=$@
fi

mkdir -p msg 

LCM_TYPES=(int8_t int16_t int32_t int64_t float   double  string boolean byte)
ROS_TYPES=(int8   int16   int32   int64   float32 float64 string bool byte)

N_TYPES=${#LCM_TYPES[@]}
unamestr=`uname`

for INFILE in $INFILES ; do
    echo "Processing LCM message file: $INFILE" >&2
    
    # Get the topic name, message type and package name
    MESSAGE_TYPE=$(cat $INFILE | awk '/struct/ {print $2}')
    PACKAGE_NAME=$(cat $INFILE | awk -F'[ ;]' '/package/ {print $2}')
    NEW_PACKAGE_NAME=$PACKAGE_NAME"_rehash"
    HASH_VALUE=$(cat $INFILE | awk '/HASH/ {print $3}')
    
    echo -n -e "\tGenerating CPP message $PACKAGE_NAME/$MESSAGE_TYPE.hpp with lcm-gen..."
    # Create lcm CPP header (in package subfolder)
    lcm-gen -x $INFILE
    test $? != 0  && { echo "LCM conversion failed, skipping $INFILE"; continue; }
    echo "done."
    
    # Create corresponding ros message
    MSGFILE="msg/$MESSAGE_TYPE.msg"
    echo -n -e "\tCreating ROS message $MSGFILE..."
    echo $(printf '#%.0s' {1..71}) > $MSGFILE
    echo "# This message was automatically generated by the lcm_to_ros package" >>$MSGFILE
    echo "# https://github.com/nrjl/lcm_to_ros, nicholas.lawrance@oregonstate.edu" >>$MSGFILE
    echo -e "$(printf '#%.0s' {1..71})\n#" >>$MSGFILE
    echo "# Source message:    $MESSAGE_NAME.msg" >> $MSGFILE
    echo "# Creation:          $(date '+%c')" >> $MSGFILE
    echo -e "#\n$(printf '#%.0s' {1..71})" >>$MSGFILE
    # sed finds lines in braces {}, removes top and tail lines, leading whitespace and semicolons
    cat $INFILE | sed '/{/,/}/!d' | sed '1d; $d; s/;//; ' | awk '{ printf "%s %s\n", $1, $2 }'> tmp
    # Convert datatypes
    for (( i=0; i<${N_TYPES}; i++ ))
    do
        if [[ "$unamestr" == 'Linux' ]]; then
           sed -i "s/\b${LCM_TYPES[$i]}\b/${ROS_TYPES[$i]}/" tmp
        elif [[ "$unamestr" == 'Darwin' ]]; then
           sed -i '.bak' "s/\b${LCM_TYPES[$i]}\b/${ROS_TYPES[$i]}/" tmp
        fi
    done
    # awk to extract array indices (if present)
    cat tmp | awk -F"[][ \t]"+ '{ 
        if (NF < 2)
            x=""
        else if (NF == 2)
            x=$1
        else {
            if ($3 ~ /^[0-9]*$/)
                x=$1"["$3"]"
            else 
                x=$1"[]"
        }; 
        printf "%-20s%s\n", x, $2}' >>$MSGFILE    
    rm tmp
    echo " done."

    if [ -z "$HASH_VALUE" ] ; then
        echo -e "\tNo valid hash value found in $INFILE, no rehash methods generated." >&2
        continue
    fi
            
    mkdir -p $NEW_PACKAGE_NAME

    # Create new hpp with overridden hash methods
    OUTFILE="$NEW_PACKAGE_NAME/$MESSAGE_TYPE.hpp"
    echo -n -e "\tCreating new header $OUTFILE with overridden hash: $HASH_VALUE " >&2

    echo $(printf '/%.0s' {1..71}) > $OUTFILE
    echo "// This message was automatically generated by $0" >>$OUTFILE
    echo "// https://github.com/nrjl/lcm_to_ros, nicholas.lawrance@oregonstate.edu" >>$OUTFILE
    echo -e "$(printf '/%.0s' {1..71})\n//" >>$OUTFILE
    echo "// Source message:    $INFILE" >> $OUTFILE
    echo "// Creation:          $(date '+%c')" >> $OUTFILE
    echo -e "//\n$(printf '/%.0s' {1..71})" >>$OUTFILE

    # Create sed replace string for replacing placeholders
    REPSTR="s:@NEW_PACKAGE_NAME@:$NEW_PACKAGE_NAME:; "
    REPSTR=$REPSTR"s:@OLD_PACKAGE_NAME@:${PACKAGE_NAME}:; "
    REPSTR=$REPSTR"s:@MESSAGE_TYPE@:$MESSAGE_TYPE:g; "
    REPSTR=$REPSTR"s:@HASH@:$HASH_VALUE:"

    # Append the replaced hpp to the output file
    cat src/lcm_rehash.hpp.in | sed  "${REPSTR}" >> $OUTFILE
    echo " done." >&2
done

