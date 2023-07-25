#!/bin/bash


## install CKAN
source /usr/lib/ckan/default/bin/activate
cd /usr/lib/ckan/default
pip install -e 'git+https://github.com/ckan/ckanext-pdfview.git#egg=ckanext-pdfview'
pip install -e 'git+https://gitlab.nectec.or.th/opend/ckanext-scheming.git#egg=ckanext-scheming'
pip install -e 'git+https://github.com/ckan/ckanext-hierarchy.git#egg=ckanext-hierarchy'
pip install -r src/ckanext-hierarchy/requirements.txt
pip install -e 'git+https://github.com/ckan/ckanext-dcat.git@v1.4.0#egg=ckanext-dcat'
pip install -r src/ckanext-dcat/requirements-py2.txt
pip install -e 'git+https://gitlab.nectec.or.th/opend/ckanext-thai_gdc.git#egg=ckanext-thai_gdc'
pip install -r src/ckanext-thai-gdc/requirements.txt
pip install -e 'git+https://gitlab.nectec.or.th/opend/ckanext-xloader.git#egg=ckanext-xloader'
pip install -r src/ckanext-xloader/requirements.txt
pip install -U requests[security]
pip install -e 'git+https://gitlab.nectec.or.th/opend/ckanext-dga-stats.git#egg=ckanext-dga-stats'
pip install -e 'git+https://gitlab.nectec.or.th/opend/ckanext-discovery.git#egg=ckanext-discovery'
pip install -e 'git+https://gitlab.nectec.or.th/opend/ckanext-pages.git#egg=ckanext-pages'
pip install -r src/ckanext-pages/requirements.txt

# config ckan
dbpassword="ckan1234"
CKAN_INI="/etc/ckan/default/ckan.ini"
ckan config-tool ${CKAN_INI} "ckan.plugins = discovery search_suggestions thai_gdc stats image_view text_view recline_view resource_proxy webpage_view datastore xloader dga_stats scheming_datasets pdf_view hierarchy_display hierarchy_form dcat dcat_json_interface structured_data pages"
ckan config-tool ${CKAN_INI} "ckan.views.default_views = image_view text_view recline_view webpage_view pdf_view"
ckan config-tool ${CKAN_INI} "ckanext.xloader.jobs_db.uri = postgresql://ckan_default:${dbpassword}@localhost/ckan_default"
ckan config-tool ${CKAN_INI} "scheming.dataset_schemas = ckanext.thai_gdc:ckan_dataset.json"
ckan config-tool ${CKAN_INI} "ckanext.xloader.just_load_with_messytables = true"
ckan config-tool ${CKAN_INI} "ckanext.xloader.ssl_verify = false"

deactivate

# restart service
sudo supervisorctl reload

##
source /usr/lib/ckan/default/bin/activate
paster --plugin=ckanext-discovery search_suggestions init -c ${CKAN_INI}
deactivate
sudo supervisorctl reload

