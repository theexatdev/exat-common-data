# การติดตั้งด้วย Docker

# ติดตั้ง Docker
```sh
curl -sSL https://raw.githubusercontent.com/theexatdev/exat-common-data/main/training/docker/install-docker.sh | bash
```

## ตรวจสอบการติดตั้ง
```sh
sudo systemctl status docker
```

## download docker compose file
```sh
git clone https://{user}:{token}@git.sbpds.com/government/exat/common/ckan-docker.git
```

### ตั้งค่าตัวแปร Environment
```sh
cd ckan-docker
cp .env.example .env
vi .env
```

```sh
# กำหนด URL
DEFAULT_URL=http(s)://{IP or DOMAIN}

# กำหนดชื่อและรหัสสำหรับบัญชีผู้ดูแลระบบ (sysadmin)
CKAN_SYSADMIN_NAME=ckan_admin
CKAN_SYSADMIN_PASSWORD=test1234
CKAN_SYSADMIN_EMAIL=your_email@example.com

# กำหนดการใช้งาน extensions (ค่าเริ่มต้นให้เป็นไปตามนี้)
CKAN__PLUGINS=envvars discovery search_suggestions exat thai_gdc stats image_view text_view recline_view resource_proxy webpage_view datastore xloader dga_stats noregistration scheming_datasets pdf_view hierarchy_display hierarchy_form dcat dcat_json_interface structured_data pages

# กำหนด default views (ค่าเริ่มต้นให้เป็นไปตามนี้)
CKAN__VIEWS__DEFAULT_VIEWS=image_view text_view recline_view webpage_view pdf_view

# กำหนด Security center Url สำหรับการทำ Single Sign on
CKANEXT__EXAT__SECURITY_CENTER__WS_ENDPOINT=https://exatservices.exat.co.th/Services_Security

```

### สร้าง Docker image
```sh
docker compose build
```

### เริ่มต้นการทำงานของ Docker containers
```sh
docker compose up -d
```

### ดูรายการบันทึก (log)
```sh
docker compose logs -f
```


### กำหนดค่าเริ่มต้นสำหรับ exat
```sh
docker compose exec -u ckan ckan sh
cd /srv/app
source /srv/app/bin/activate
paster --plugin=ckanext-discovery search_suggestions init -c/srv/app/ckan.ini
ckan -c /srv/app/ckan.ini exat-init
deactivate
exit
```