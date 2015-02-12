#!/bin/bash
#
# Database Backup script.
# Created By:    Jeffrey Cohen
#                BluePrint IT
#                Date: 09/02/2015
#				 Version 1.0

backupdir='/data/myexport/'

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"

# Commands
mysqldump='/usr/bin/mysqldump';
mysql='/usr/bin/mysql';
gzip='/usr/bin/gzip';
egrep='/usr/bin/egrep'

#Backup
echo "Exporting databaes..."
	#Loop true databases.
	for db in `mysql -e'show databases'`; do
		echo "Prepairing $db"
		cd $backupdir
		mkdir $db$$
		cd $db$$
		clear
		#looping true tables.
		for table in `$mysql $db -e 'show tables' | $egrep -v 'Tables_in_' `; do
			echo "Dumping $table"
			# Routines
			$mysqldump --single-transaction --no-data -R $db $table  |$gzip > $table.sql.tar.gz&
			# export
			$mysqldump --single-transaction --no-data $db $table  |$gzip >> $table.sql.tar.gz&
			# data
			$mysqldump --single-transaction --master-data --no-create-db --no-create-info $db $table |$gzip >> $table.sql.tar.gz&
		done
		if [ "$table" = "" ]; then
			echo "No tables found in db: $db"
		fi
	done
echo "Export done validating..."
#Integrity Check.... [OK/FAILED] 
begin=$(date +"%s")
	for tars in $(find . -iname "*.tar.gz" -mtime -1 -exec ls {} \;); 
		do tar -zxf $tars &> /dev/null 
		 if [ $? -ne 0 ]
	  then
	    echo -e `PWD`/$tars		["$COL_RED"FAILED"$COL_RESET"]
	    else
	  	echo -e `PWD`/$tars		["$COL_GREEN"OK"$COL_RESET"] 
	  fi
	done
termin=$(date +"%s")
difftimelps=$(($termin-$begin))
echo "Validated in $(($difftimelps / 60)) minutes and $(($difftimelps % 60)) seconds."