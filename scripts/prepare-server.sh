#!/bin/bash

sudo apt-get update -y

## install postgresql
sudo apt-get install -y postgresql

## install Apache Solr
sudo apt-get install -y openjdk-8-jdk
sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
wget http://archive.apache.org/dist/lucene/solr/6.5.1/solr-6.5.1.tgz
tar xzf solr-6.5.1.tgz solr-6.5.1/bin/install_solr_service.sh --strip-components=2
sudo bash ./install_solr_service.sh solr-6.5.1.tgz

## packages for CKAN
sudo apt-get install -y python-dev libpq-dev redis-server git build-essential
sudo add-apt-repository universe
sudo apt install -y python2
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1
sudo update-alternatives --config python
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2 get-pip.py
sudo apt install -y virtualenv

## prepare directory
mkdir -p ~/ckan/lib
mkdir -p ~/ckan/var
mkdir -p ~/ckan/etc

# ckan path
sudo mkdir -p /usr/lib/ckan/default
sudo chown -R `whoami` /usr/lib/ckan/default

# storage path
sudo mkdir -p /var/lib/ckan/default
sudo chown -R `whoami` /var/lib/ckan/default && sudo chmod -R 775 /var/lib/ckan

# etc path
sudo mkdir -p /etc/ckan/default
sudo chown -R `whoami` /etc/ckan/default

## config Apache Solr
sudo su solr
cd /opt/solr/bin
./solr create -c ckan
cd /var/solr/data/ckan/conf
mv solrconfig.xml solrconfig.xml.bak
wget https://raw.githubusercontent.com/ckan/ckan/ckan-2.9.5/contrib/docker/solr/solrconfig.xml
rm managed-schema
ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml schema.xml
exit
sudo service solr restart
cd ~

## create postgresql user and db
dbpassword="ckan1234"
export PGPASSWORD="$dbpassword"
echo "Please password as ckan1234"
sudo -u postgres createuser -S -D -R -P ckan_default
sudo -u postgres createdb -O ckan_default ckan_default -E utf-8
sudo -u postgres createdb -O ckan_default datastore_default -E utf-8
sudo -u postgres createuser -S -D -R -P -l datastore_default

unset PGPASSWORD

## python environment
virtualenv --python=python2 /usr/lib/ckan/default
source /usr/lib/ckan/default/bin/activate
cd /usr/lib/ckan/default
pip install --upgrade pip
pip install setuptools==44.1.0
deactivate
