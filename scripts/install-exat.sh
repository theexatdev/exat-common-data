#!/bin/bash

if [ -z "$GIT_URL" ]; then
    echo "ERROR: GIT_URL environment variable is not set or empty."
    exit 1
fi

source /usr/lib/ckan/default/bin/activate
cd /usr/lib/ckan/default/src
git clone ${GIT_URL} ckanext-exat
cd /usr/lib/ckan/default/src/ckanext-exat
pip install -e .
pip install -r requirements.txt

cd /usr/lib/ckan/default
CKAN_INI="/etc/ckan/default/ckan.ini"
ckan config-tool ${CKAN_INI} "ckanext.exat.security_center.ws_endpoint = https://exatservices.exat.co.th/Services_Security"
ckan config-tool ${CKAN_INI} "ckanext.exat.security_center.client = ckanext.exat.lib.security_center:SoapSecurityClient"
ckan config-tool ${CKAN_INI} "ckanext.exat.assign_default_organization = true"
ckan config-tool ${CKAN_INI} "ckanext.exat.assign_personnel_organization = false"
ckan config-tool ${CKAN_INI} "ckanext.exat.override_stats = true"
ckan config-tool ${CKAN_INI} "ckan.plugins = discovery search_suggestions exat thai_gdc stats image_view text_view recline_view resource_proxy webpage_view datastore xloader dga_stats scheming_datasets pdf_view hierarchy_display hierarchy_form dcat dcat_json_interface structured_data pages"

deactivate

sudo supervisorctl reload