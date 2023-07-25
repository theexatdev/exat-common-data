#!/bin/bash

##
source /usr/lib/ckan/default/bin/activate
paster --plugin=ckanext-discovery search_suggestions init -c ${CKAN_INI}

sudo chown -R ckan:www-data /var/lib/ckan/default
ckan -c /etc/ckan/default/ckan.ini exat-init
sudo chown -R www-data:www-data /var/lib/ckan/default

deactivate
sudo supervisorctl reload