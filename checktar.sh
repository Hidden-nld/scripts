#!/bin/bash
#
# tar test script.
# Created By:    Jeffrey Cohen
#                BluePrint IT
#                Date: 09/02/2015
#				 Version 1.0

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"

begin=$(date +"%s")
# fins all tar files with max age of 1 day
for tars in $(find . -iname "*.tar.gz" -mtime -1 -exec ls {} \;); 
	#extract to nowhere and suppress output.
	do tar -zxf $tars &> /dev/null 
	# check exit code and flag [OK/FAILED]
	 if [ $? -ne 0 ]
  then
    echo -e `PWD`/$tars		["$COL_RED"FAILED"$COL_RESET"]
  else
  	echo -e `PWD`/$tars		["$COL_GREEN"OK"$COL_RESET"] 
  fi
done
#Calculate proccess time
termin=$(date +"%s")
difftimelps=$(($termin-$begin))
echo "$(($difftimelps / 60)) minutes and $(($difftimelps % 60)) seconds."
		