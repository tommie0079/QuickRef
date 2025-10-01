A fully functional website hosted on a Synology NAS, running in Docker containers. 
The website integrates SMTP for email functionality and uses a MySQL database.

Management:
```
phpMyAdmin   localhost:8080
Website      localhost:5500
```
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
Run compose.yaml true Container Manager

# 3. Modify www folder:
chmod -R a+rX www

## 4. Import mysql database
## 5. Edit .env and db.env
