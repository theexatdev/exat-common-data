#!/bin/bash

##
source /usr/lib/ckan/default/bin/activate
paster --plugin=ckanext-discovery search_suggestions init -c ${CKAN_INI}
deactivate
sudo supervisorctl reload