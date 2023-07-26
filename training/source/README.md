# การติดตั้งจาก Source code

## ติดตั้งโปรแกรม และ package ที่จำเป็น
```sh
curl -sSL https://raw.githubusercontent.com/theexatdev/exat-common-data/main/training/source/prepare-server.sh | bash
```

### ตรวจสอบการทำงาน
```sh
sudo systemctl status postgresql
sudo systemctl status solr
```

### ตั้งค่า environment variable
```sh
export CKAN_DB_PASSWORD="{รหัสที่ได้ตั้งไว้}"
export CKAN_DATASTORE_PASSWORD="{รหัสที่ได้ตั้งไว้}"
```

## ตั้งค่า CKAN
```sh
curl -sSL https://raw.githubusercontent.com/theexatdev/exat-common-data/main/training/source/config-ckan.sh | bash
```

## ติดตั้ง extensions สำหรัน Open-D
```sh
curl -sSL https://raw.githubusercontent.com/theexatdev/exat-common-data/main/training/source/install-opend.sh | bash
```

## ตั้งค่า cron job
```sh
curl -sSL https://raw.githubusercontent.com/theexatdev/exat-common-data/main/training/source/cron-jobs.sh | bash
```


## ติดตั้ง extension ckanext-exat
```sh
export GIT_URL="{git url} เช่น https://{user}:{token}@git.sbpds.com/government/exat/common/ckanext.git"
curl -sSL https://raw.githubusercontent.com/theexatdev/exat-common-data/main/training/source/install-exat.sh | bash
```

### initialial extension
```sh
curl -sSL https://raw.githubusercontent.com/theexatdev/exat-common-data/main/training/source/init-extensions.sh | bash
```

### เพิ่ม sysadmin
```sh
cd /usr/lib/ckan/default
source /usr/lib/ckan/default/bin/activate
sudo chown -R ckan:www-data /var/lib/ckan/default
ckan -c /etc/ckan/default/ckan.ini sysadmin add ckan_admin
sudo chown -R www-data:www-data /var/lib/ckan/default
deactivate
```