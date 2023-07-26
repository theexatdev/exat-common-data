#!/bin/bash

## cron job
cronjob1="@hourly /usr/lib/ckan/default/bin/ckan -c /etc/ckan/default/ckan.ini tracking update && /usr/lib/ckan/default/bin/ckan -c /etc/ckan/default/ckan.ini search-index rebuild -r"
cronjob2="@daily /usr/lib/ckan/default/bin/paster --plugin=ckanext-xloader xloader submit all -c /etc/ckan/default/ckan.ini"

# Add both cronjob entries to the current user's crontab
(crontab -l ; echo "$cronjob1" ; echo "$cronjob2") | crontab -