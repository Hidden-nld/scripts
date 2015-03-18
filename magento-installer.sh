#!/bin/bash
#
# Magento Install script.
# Created By:    Jeffrey Cohen
#                BluePrint IT
#                Date: 09/02/2015
#                Version 1.0


    PHP_PATH="/usr/bin/php"
    MAGENTO_VERSION="1.9.1.0"
    BASE_DIR="html"
    DOWNLOAD_DIR="/tmp/"
clear

stty erase '^?'

###########################
# Collecting Install data #
###########################

echo "Magento $MAGENTO_VERSION Installer"
echo -n "Database Name: "
read DBNAME
echo -n "Database User: "
read DBUSER
echo -n "Database Password: "
read DBPASS
echo -n "Database Socket: "
read DB_SOCKET
echo -n "Admin name: "
read ADMIN_NAME
echo -n "$ADMIN_NAME Password: "
read ADMIN_PASS
echo -n "Admin E-mail: "
read ADMIN_EMAIL
echo -n "Store URL [http://localhost/] (with trailing slash): "
read URL
echo -n "Include Sample Data? [Y/n] "
read SAMPLE_DATA

##############################
# Installer with sample data #
##############################

    echo
    echo "Now installing Magento..."
    

    
    if [ -f $DOWNLOAD_DIRmagento-$MAGENTO_VERSION.tar.gz ]; then
        echo
        echo "Already downloaded magento-$MAGENTO_VERSION.tar.gz"
        echo
    else
        echo
        echo "Downloading packages..."
        echo
        wget http://www.magentocommerce.com/downloads/assets/$MAGENTO_VERSION/magento-$MAGENTO_VERSION.tar.gz -p $DOWNLOAD_DIR
    fi

    if [[ $SAMPLE_DATA == 'y' || $SAMPLE_DATA == 'Y' ]]; then
        if [ -f $DOWNLOAD_DIRmagento-sample-data-$MAGENTO_VERSION.tar.gz ]; then
            echo
            echo "Already downloaded magento-sample-data-$MAGENTO_VERSION.tar.gz"
            echo
        else
            echo
            echo "Downloading packages..."
            echo
            wget http://www.magentocommerce.com/downloads/assets/$MAGENTO_VERSION/magento-sample-data-$MAGENTO_VERSION.tar.gz -p $DOWNLOAD_DIR
        fi
    fi
    echo
    echo "Extracting data..."
    echo
    
    tar xf $DOWNLOAD_DIRmagento-$MAGENTO_VERSION.tar.gz -C $PWD$DOWNLOAD_DIR
    if [[ $SAMPLE_DATA == 'y' || $SAMPLE_DATA == 'Y' ]]; then
        tar xf $DOWNLOAD_DIRmagento-sample-data-$MAGENTO_VERSION.tar.gz -C $PWD$DOWNLOAD_DIR
    fi
    echo
    echo "Moving files..."
    echo
    
    if [[ $SAMPLE_DATA == 'y' || $SAMPLE_DATA == 'Y' ]]; then
        mv magento-sample-data-$MAGENTO_VERSION/media/* magento/media/
        mv magento-sample-data-$MAGENTO_VERSION/magento_sample_data_for_$MAGENTO_VERSION.sql magento/data.sql
    fi
    mv magento/* magento/.htaccess .
    
    echo
    echo "Setting permissions..."
    echo
    
    chmod +x mage
    
    if [[ $SAMPLE_DATA == 'y' || $SAMPLE_DATA == 'Y' ]]; then
        echo
        echo "Importing sample products..."
        echo
    
        mysql -h localhost -u $DBUSER -p$DBPASS $DBNAME -S$DB_SOCKET< data.sql
    fi
    echo
    echo "Initializing PEAR registry..."
    echo
    
    ./mage mage-setup .
    ./mage config-set preferred_state stable`
    
    echo
    echo "Installing core extensions..."
    echo
    
    ./mage install http://connect20.magentocommerce.com/community Mage_All_Latest --force
    
    echo
    echo "Refreshing indexes..."
    echo
    
    $PHP_PATH -f shell/indexer.php reindexall
    
    echo
    echo "Cleaning up files..."
    echo

    if [[ $SAMPLE_DATA == 'y' || $SAMPLE_DATA == 'Y' ]]; then
        rm -rf magento/ magento-sample-data-$MAGENTO_VERSION/
    fi
    rm -rf *.sample *.txt data.sql
    
    echo
    echo "Installing Magento..."
    echo
    
    $PHP_PATH -f install.php -- \
    --license_agreement_accepted "yes" \
    --locale "nl_NL" \
    --timezone "Europe/Amsterdam" \
    --default_currency "USD" \
    --db_host "DB_SOCKET" \
    --db_name "$DBNAME" \
    --db_user "$DBUSER" \
    --db_pass "$DBPASS" \
    --url "$URL" \
    --use_rewrites "yes" \
    --use_secure "no" \
    --secure_base_url "" \
    --use_secure_admin "no" \
    --admin_firstname "Store" \
    --admin_lastname "Owner" \
    --admin_email "ADMIN_EMAIL" \
    --admin_username "$ADMIN_NAME" \
    --admin_password "$ADMIN_PASS"

    if [[ $SAMPLE_DATA == 'y' || $SAMPLE_DATA == 'Y' ]]; then
        echo
        echo "Finished installing the latest stable version of Magento with Sample Data"
        echo
    else
        echo
        echo "Finished installing the latest stable version of Magento without Sample Data"
        echo
    fi
    echo "+=================================================+"
    echo "| MAGENTO LINKS"
    echo "+=================================================+"
    echo "|"
    echo "| Store: $URL"
    echo "| Admin: ${URL}admin/"
    echo "|"
    echo "+=================================================+"
    echo "| ADMIN ACCOUNT"
    echo "+=================================================+"
    echo "|"
    echo "| Username: $ADMIN_NAME"
    echo "| Password: $ADMIN_PASS"
    echo "| Admin e-mail: $ADMIN_EMAIL"
    echo "|"
    echo "+=================================================+"
    echo "| DATABASE INFO"
    echo "+=================================================+"
    echo "|"
    echo "| Database: $DBNAME"
    echo "| Username: $DBUSER"
    echo "| Password: $DBPASS"
    echo "|"
    echo "+=================================================+"
    
exit
