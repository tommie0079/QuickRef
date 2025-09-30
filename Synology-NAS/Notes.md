A fully functioning website hosted on Synology NAS, run true docker containers. 

Management:
phpMyAdmin   localhost:8080
Website      localhost:5500




This website uses smtp mail and mysql database.

# 1. Folder setup:

```
myproject/
├── nginx/
│   └── default.conf
├── php/
│   └── Dockerfile
├── www/
│   ├── index.php
│   ├── .env
│   └── phpmailer/   (manually downloaded PHPMailer)
├── compose.yml
├── db.env
```

# 2. Modify www folder:
chmod -R a+rX www
