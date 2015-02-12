#!/bin/bash
#
# Solradmin.
# Created By:    Jeffrey Cohen
#                BluePrint IT
#                Date: 09/02/2015
#				 Version 1.0


#variables
SOLRROOT=/usr/share/apache-solr/example/solr
SOLRDATA=$SOLRROOT
SOLRCONF=$SOLRROOT/$CORENAME/conf						
SOLRCONFTEMPLATE=$SOLRROOT/templatecore
SOLRSERVER=127.0.0.1
SOLRPORT=8983
LOGFILE=/var/log/solradmin.log
OWNER=root.root

ACTION=$1
CORENAME=$2
CORENAME2=$3

# creates a new Solr core
if [ "$ACTION" = "create" ]; then
	if [ "$CORENAME" = "" ]; then
		echo -n "Name of core to create: "
		read CORENAME
	fi
        if [  -d $SOLRDATA/$CORENAME ] || [ $CORENAME = "" ]; then
                echo "Core already exist"
                exit
        fi
	mkdir $SOLRDATA/$CORENAME
#	chown $OWNER $SOLRDATA/$CORENAME #currently root so no need for change

	cp -r $SOLRCONFTEMPLATE/* $SOLRROOT/$CORENAME
	sed "s/example/$CORENAME/" $SOLRROOT/$CORENAME/conf/schema.xml > $SOLRROOT/$CORENAME/conf/schema.tmp # set nice corename
	cp $SOLRROOT/$CORENAME/conf/schema.tmp $SOLRROOT/$CORENAME/conf/schema.xml
	sed "s/.*<\/cores>.*/         <core name=\"$CORENAME\" instanceDir=\"$CORENAME\" \/>\n&/" $SOLRDATA/solr.xml > $SOLRDATA/solr.tmp
	cp $SOLRDATA/solr.tmp $SOLRDATA/solr.xml
	curl --silent "http://$SOLRSERVER:$SOLRPORT/solr/admin/cores?action=CREATE&name=$CORENAME&instanceDir=$SOLRDATA/$CORENAME" > /dev/nul #load core
	echo `date` $ACTION $CORENAME >> $LOGFILE
	echo Created $CORENAME
	exit 0
fi

# Reload a Core
if [ "$ACTION" = "reload" ]; then
	if [ "$CORENAME" = "" ]; then
		echo -n "Name of core to reload: "
		read CORENAME
	fi

	if [ ! -d $SOLRDATA/$CORENAME ] || [ $CORENAME = "" ]; then
		echo "Core doesn't exist"
		exit
	fi

	curl --silent "http://$SOLRSERVER:$SOLRPORT/solr/admin/cores?action=RELOAD&core=$CORENAME" > /dev/nul
        echo `date` $ACTION $CORENAME >> $LOGFILE
        echo Reload $CORENAME 
	exit 0
fi

# swaps two Solr cores
#
# not ready
#if [ "$ACTION" = "swap" ]; then
#	if [ "$CORENAME2" = "" ]; then
#		echo -n "Name of first core: "
#		read CORENAME
#		echo -n "Name of second core: "
#		read CORENAME2
#	fi
#
#	if [ ! -d $SOLRDATA/$CORENAME ] || [ $CORENAME2 = "" ]; then
#		echo "Core doesn't exist"
#		exit
#	fi
#
#	curl --silent "http://$SOLRSERVER:$SOLRPORT/solr/admin/cores?action=SWAP&core=$name1&other=$CORENAME2" > /dev/nul
#        echo `date` $ACTION $CORENAME $CORENAME2 >> $LOGFILE
#        echo swapped $CORENAME $CORENAME2
#
#	exit 0
#fi

# Delete a Core
if [ "$ACTION" = "delete" ]; then
	clear
	echo "*************************************************************************"
	echo "*************************************************************************"
	echo ""
	echo "            You are about to *permanently* delete a core!"
	echo "                      There is no going back"
	echo ""
	echo "*************************************************************************"
	echo "*************************************************************************"
	echo
	echo -n "Type 'delete core' to continue or control-c to bail: "
	read answer

	if [ "$answer" != "delete core" ]; then
		exit
	fi
	# removes a Solr core
	if [ "$CORENAME" = "" ]; then
		echo -n "Name of core to remove: "
		read CORENAME
	fi

	if [ ! -d $SOLRDATA/$CORENAME ] || [ $CORENAME = "" ]; then
		echo "Core doesn't exist"
		exit
	fi
	echo Please wait....
# needs to delete config line from $SOLRDATA/solr.xml
#	sed 		#remove core from config
	sed "/$CORENAME/d" $SOLRDATA/solr.xml > $SOLRDATA/solr.tmp
        cp $SOLRDATA/solr.tmp $SOLRDATA/solr.xml
	curl --silent "http://$SOLRSERVER:$SOLRPORT/solr/admin/cores?action=UNLOAD&core=$CORENAME" > /dev/nul/
	sleep 5
	rm -rf $SOLRDATA/$CORENAME
        echo `date` $ACTION $CORENAME >> $LOGFILE
        echo DELETED $CORENAME
	exit 0
fi

# merges two Solr cores
if [ "$ACTION" = "merg" ]; then
	if [ "$CORENAME2" = "" ]; then
		echo -n "Name of first core: "
		read CORENAME
		echo -n "Name of second core: "
		read CORENAME2
	fi

	if [ ! -d $SOLRDATA/$CORENAME ] || [ $CORENAME2 = "" ]; then
		echo "Core doesn't exist"
		exit
	fi

	curl --silent "http://$SOLRSERVER:$SOLRPORT/solr/$CORENAME/update" --data-binary '' -H 'Content-type:text/xml; charset=utf-8' > /dev/nul
	curl --silent "http://$SOLRSERVER:$SOLRPORT/solr/$CORENAME2/update" --data-binary '' -H 'Content-type:text/xml; charset=utf-8' > /dev/nul
	curl --silent "http://$SOLRSERVER:$SOLRPORT/solr/admin/cores?action=mergeindexes&core=$CORENAME&indexDir=$SOLRDATA/$CORENAME2/index" > /dev/nul
	curl --silent "http://$SOLRSERVER:$SOLRPORT/solr/$CORENAME/update" --data-binary '' -H 'Content-type:text/xml; charset=utf-8' > /dev/nul
	curl --silent "http://$SOLRSERVER:$SOLRPORT/solr/$CORENAME2/update" --data-binary '' -H 'Content-type:text/xml; charset=utf-8' > /dev/nul
        echo `date` $ACTION $CORENAME >> $LOGFILE
        echo merged $CORENAME $CORENAME2
	exit 0
fi	

#show cores
# nice but need some work :)
if [ "$ACTION" = "show" ];then
	ls $SOLRDATA
	exit 0
fi
	
# Display Usage

	echo 'Usage: acton [core1] [core2]'
	echo ''
	echo 'create: Creating a new core'
	echo 'Reload: Reloading a core'
	echo 'swap: swapping a core Not yet functional'
	echo 'delete: Deleting a core'
	echo 'merge: Merg cores'
	echo 'show: show cores'
	echo ''
	exit 0
# central logging disabled
#
#if [ $CORENAME2 = "" ]; then
#	echo 'date' $ACTION $CORENAME >>  $LOGFILE 
#	echo $ACTION $CORENAME
#else
#	echo 'date' $ACTION $CORENAME $CORENAME2 >>  $LOGFILE
#	echo $ACTION $CORENAME $CORENAME2
#fi
exit 0
