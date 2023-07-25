#!/bin/bash

### STATE 1 ###

# sudo apt-get update -y

# ## install postgresql
# sudo apt-get install -y postgresql

# ## install Apache Solr
# sudo apt-get install -y openjdk-8-jdk
# sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
# wget http://archive.apache.org/dist/lucene/solr/6.5.1/solr-6.5.1.tgz
# tar xzf solr-6.5.1.tgz solr-6.5.1/bin/install_solr_service.sh --strip-components=2
# sudo bash ./install_solr_service.sh solr-6.5.1.tgz

# ## packages for CKAN
# sudo apt-get install -y python-dev libpq-dev redis-server git build-essential
# sudo add-apt-repository universe
# sudo apt install -y python2
# sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1
# sudo update-alternatives --config python
# curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
# sudo python2 get-pip.py
# sudo apt install -y virtualenv

# ## prepare directory
# mkdir -p ~/ckan/lib
# mkdir -p ~/ckan/var
# mkdir -p ~/ckan/etc

# # ckan path
# sudo mkdir -p /usr/lib/ckan/default
# sudo chown -R `whoami` /usr/lib/ckan/default

# # storage path
# sudo mkdir -p /var/lib/ckan/default
# sudo chown -R `whoami` /var/lib/ckan/default && sudo chmod -R 775 /var/lib/ckan

# # etc path
# sudo mkdir -p /etc/ckan/default
# sudo chown -R `whoami` /etc/ckan/default

# ## config Apache Solr
# sudo su solr
# cd /opt/solr/bin
# ./solr create -c ckan
# cd /var/solr/data/ckan/conf
# mv solrconfig.xml solrconfig.xml.bak
# wget https://raw.githubusercontent.com/ckan/ckan/ckan-2.9.5/contrib/docker/solr/solrconfig.xml
# rm managed-schema
# ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml schema.xml
# exit
# sudo service solr restart
# cd ~

# ## python environment
# virtualenv --python=python2 /usr/lib/ckan/default
# source /usr/lib/ckan/default/bin/activate
# cd /usr/lib/ckan/default
# pip install --upgrade pip
# pip install setuptools==44.1.0
# deactivate

# ## install CKAN
# source /usr/lib/ckan/default/bin/activate
# cd /usr/lib/ckan/default
# pip install -e 'git+https://github.com/ckan/ckan.git@ckan-2.9.5#egg=ckan[requirements-py2]'
# deactivate

### END STATE 1 ###
### STATE 2 ###

# ## create postgresql user and db
# dbpassword="ckan1234"
# export PGPASSWORD="$dbpassword"
# echo "Please password as ckan1234"
# sudo -u postgres createuser -S -D -R -P ckan_default
# sudo -u postgres createdb -O ckan_default ckan_default -E utf-8
# sudo -u postgres createdb -O ckan_default datastore_default -E utf-8
# sudo -u postgres createuser -S -D -R -P -l datastore_default

# unset PGPASSWORD

# ## config who.ini
# sudo ln -s /usr/lib/ckan/default/src/ckan/who.ini /etc/ckan/default/who.ini
# sudo chown -R `whoami` /etc/ckan/

# # Get the host IP address based on the operating system
# if [[ "$os" == "Darwin" ]]; then
#     # macOS
#     host_ip=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}')
# else
#     # Ubuntu and other Linux distributions
#     host_ip=$(hostname -I | awk '{print $1}')
# fi

# # config ckan
# CKAN_INI="/etc/ckan/default/ckan.ini"
# source /usr/lib/ckan/default/bin/activate
# cd /usr/lib/ckan/default
# ckan generate config /etc/ckan/default/ckan.ini
# ckan config-tool ${CKAN_INI} "sqlalchemy.url = postgresql://ckan_default:${dbpassword}@localhost/ckan_default"
# ckan config-tool ${CKAN_INI} "ckan.datastore.write_url = postgresql://ckan_default:${dbpassword}@localhost/datastore_default"
# ckan config-tool ${CKAN_INI} "ckan.datastore.read_url = postgresql://datastore_default:${dbpassword}@localhost/datastore_default"
# ckan config-tool ${CKAN_INI} "ckan.site_url = http://${host_ip}"
# ckan config-tool ${CKAN_INI} "solr_url = http://127.0.0.1:8983/solr/ckan"
# ckan config-tool ${CKAN_INI} "ckan.redis.url = redis://localhost:6379/0"
# ckan config-tool ${CKAN_INI} "ckan.storage_path = /var/lib/ckan/default"
# ckan config-tool ${CKAN_INI} "ckan.upload.user.mimetypes = image/png image/jpg image/gif"
# ckan config-tool ${CKAN_INI} "ckan.locale_default = th"
# ckan config-tool ${CKAN_INI} "ckan.locale_order = en th"
# ckan config-tool ${CKAN_INI} "ckan.auth.allow_dataset_collaborators = true"
# ckan config-tool ${CKAN_INI} "ckanext.exat.security_center.ws_endpoint = https://exatservices.exat.co.th/Services_Security"
# ckan config-tool ${CKAN_INI} "ckanext.exat.security_center.client = ckanext.exat.lib.security_center:SoapSecurityClient"
# ckan config-tool ${CKAN_INI} "ckanext.exat.assign_default_organization = true"
# ckan config-tool ${CKAN_INI} "ckanext.exat.assign_personnel_organization = false"
# ckan config-tool ${CKAN_INI} "ckanext.exat.override_stats = true"

# ckan -c ${CKAN_INI} db init
# ckan -c ${CKAN_INI} datastore set-permissions | sudo -u postgres psql --set ON_ERROR_STOP=1

# deactivate

### END STATE 2 ###
### STATE 3 ###

## setup uwsgi
source /usr/lib/ckan/default/bin/activate
pip install uwsgi
deactivate
cp /usr/lib/ckan/default/src/ckan/ckan-uwsgi.ini /etc/ckan/default/
cp /usr/lib/ckan/default/src/ckan/wsgi.py /etc/ckan/default/

# setup supervisor
sudo apt-get install -y supervisor
sudo mkdir -p /var/log/ckan
#sudo vi /etc/supervisor/conf.d/ckan-uwsgi.conf
cat << EOF | sudo tee "/etc/supervisor/conf.d/ckan-uwsgi.conf" > /dev/null
[program:ckan-uwsgi]
command=/usr/lib/ckan/default/bin/uwsgi -i /etc/ckan/default/ckan-uwsgi.ini
numprocs=1
process_name=%(program_name)s-%(process_num)02d
stdout_logfile=/var/log/ckan/ckan-uwsgi.stdout.log
stderr_logfile=/var/log/ckan/ckan-uwsgi.stderr.log
autostart=true
autorestart=true
startsecs=10
stopwaitsecs = 600
stopsignal=QUIT
EOF

## nginx
sudo apt-get install -y nginx
#sudo vi /etc/nginx/sites-available/ckan
cat << EOF | sudo tee "/etc/nginx/sites-available/ckan" > /dev/null
proxy_cache_path /var/cache/nginx/proxycache levels=1:2 keys_zone=cache:30m max_size=250m;
proxy_temp_path /tmp/nginx_proxy 1 2;

server {
    client_max_body_size 100M;
    server_tokens off;
    location / {
        proxy_pass http://127.0.0.1:8080/;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
        proxy_cache cache;
        proxy_cache_bypass $cookie_auth_tkt;
        proxy_no_cache $cookie_auth_tkt;
        proxy_cache_valid 30m;
        proxy_cache_key $host$scheme$proxy_host$request_uri;
    }
}
EOF

sudo rm -r /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/ckan /etc/nginx/sites-enabled/ckan
sudo mkdir -p /var/cache/nginx/proxycache && sudo chown www-data /var/cache/nginx/proxycache

# file permissions
sudo chown -R www-data:www-data /var/lib/ckan
sudo chown -R www-data:www-data /usr/lib/ckan/default/src/ckan/ckan/public
sudo chown -R www-data:www-data /var/lib/ckan/default

# restart service
sudo supervisorctl reload
sudo service nginx restart
