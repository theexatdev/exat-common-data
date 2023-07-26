#!/bin/bash

if [ -z "$CKAN_DB_PASSWORD" ]; then
    echo "ERROR: CKAN_DB_PASSWORD environment variable is not set or empty."
    exit 1
fi

if [ -z "$CKAN_DATASTORE_PASSWORD" ]; then
    echo "ERROR: CKAN_DATASTORE_PASSWORD environment variable is not set or empty."
    exit 1
fi

## install CKAN
source /usr/lib/ckan/default/bin/activate
cd /usr/lib/ckan/default
pip install -e 'git+https://github.com/ckan/ckan.git@ckan-2.9.5#egg=ckan[requirements-py2]'
deactivate

## config who.ini
sudo ln -s /usr/lib/ckan/default/src/ckan/who.ini /etc/ckan/default/who.ini
sudo chown -R `whoami` /etc/ckan/

# Get the host IP address based on the operating system
if [[ "$os" == "Darwin" ]]; then
    # macOS
    host_ip=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}')
else
    # Ubuntu and other Linux distributions
    host_ip=$(hostname -I | awk '{print $1}')
fi

# config ckan
CKAN_INI="/etc/ckan/default/ckan.ini"
source /usr/lib/ckan/default/bin/activate
cd /usr/lib/ckan/default
ckan generate config /etc/ckan/default/ckan.ini
ckan config-tool ${CKAN_INI} "sqlalchemy.url = postgresql://ckan_default:${CKAN_DB_PASSWORD}@localhost/ckan_default"
ckan config-tool ${CKAN_INI} "ckan.datastore.write_url = postgresql://ckan_default:${CKAN_DB_PASSWORD}@localhost/datastore_default"
ckan config-tool ${CKAN_INI} "ckan.datastore.read_url = postgresql://datastore_default:${CKAN_DATASTORE_PASSWORD}@localhost/datastore_default"
ckan config-tool ${CKAN_INI} "ckan.site_url = http://${host_ip}"
ckan config-tool ${CKAN_INI} "solr_url = http://127.0.0.1:8983/solr/ckan"
ckan config-tool ${CKAN_INI} "ckan.redis.url = redis://localhost:6379/0"
ckan config-tool ${CKAN_INI} "ckan.storage_path = /var/lib/ckan/default"
ckan config-tool ${CKAN_INI} "ckan.upload.user.mimetypes = image/png image/jpg image/gif"
ckan config-tool ${CKAN_INI} "ckan.locale_default = th"
ckan config-tool ${CKAN_INI} "ckan.locale_order = en th"
ckan config-tool ${CKAN_INI} "ckan.auth.allow_dataset_collaborators = true"

ckan -c ${CKAN_INI} db init
ckan -c ${CKAN_INI} datastore set-permissions | sudo -u postgres psql --set ON_ERROR_STOP=1

paster --plugin=ckanext-discovery search_suggestions init -c ${CKAN_INI}

deactivate

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
cat << 'EOF' | sudo tee "/etc/nginx/sites-available/ckan" > /dev/null
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
        proxy_cache_key ${host}${scheme}${proxy_host}$request_uri;
        # In emergency comment out line to force caching
        # proxy_ignore_headers X-Accel-Expires Expires Cache-Control;
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