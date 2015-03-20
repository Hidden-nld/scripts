#!/bin/bash
#
# Domainvalidate.
# Created By:    Jeffrey Cohen
#                Date: 09/02/2015
#                                Version 1.0

#variables
vhost=/etc/apache2/vhost.d/


echo " Building domain list"
grep -i -r -E "ServerName|ServerAlias" /etc/apache2/vhosts.d/*.conf |grep -v "#" | awk '{print $3}' > /tmp/domainlist1.tmp
echo "Domain list done!"

echo " Trying to ping domain names..."
#or domain in `cat /tmp/domainlist.tmp` ; 
#do ping -c 1 $domain |head -n 1 | awk '{print $3, $2}' > /tmp/domainlist.tmp ; 
#one 
for p in `cat /tmp/domainlist1.tmp` ; do ping -c 1 $p |head -n 1 | awk '{print $3, $2}' >> /tmp/domainlist.tmp ; done
echo " Ping scan done!"

echo "Find local ip's"
ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1' > /tmp/myips.tmp

echo " Sorting domains"
grep 80.84.237.179 /tmp/domainlist.tmp > /tmp/domains-on-this-server.txt
grep -v 80.84.237.179 /tmp/domainlist.tmp > /tmp/moved-domains.txt
grep unknown /tmp/domainlist.tmp > /tmp/unknown.txt

echo "+=============================================+"
echo "| domains in vhosts                           |"
echo "| /tmp/domainlist1.tmp                        |"
echo "|                                             |"
echo "| domains and ips                             |"
echo "| /tmp/domainlist.tmp                         |"
echo "|                                             |"
echo "| domains on this server                      |"
echo "| /tmp/domains-on-this-server.txt             |"
echo "|                                             |"
echo "| domains no longer on this server            |"
echo "| /tmp/moved-domains.txt                      |"
echo "|                                             |"
echo "| Unknown domains                             |"
echo "| /tmp/unknown.txt                            |"
echo "+=============================================+"
exit
