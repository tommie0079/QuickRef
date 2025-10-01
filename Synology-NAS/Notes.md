A fully functional website hosted on a Synology NAS, running in Docker containers. 
The website integrates SMTP for email functionality and uses a MySQL database.

Management:
```
phpMyAdmin   localhost:8080
Website      localhost:5500
```
## 1. Folder setup:

```
myproject/
├── nginx/
│   └── default.conf
├── www/
│   ├── db.php
│   ├── loadEnv.php
│   ├── mailer.php
│   ├── test_smtp.php
│   ├── .env (smtp + db)
│   └── phpmailer/   (manually downloaded PHPMailer)
│       └── DSNConfigurator.php
│       ├── Exception.php
│       ├── OAuth.php
│       ├── OAuthTokenProvider.php
│       ├── PHPMailer.php
│       ├── POP3.php
│       ├── SMTP.php
├── .env (db)
├── docker-compose.yml
├── Dockerfile
```
## 2. Install Container Manager

## 3. Modify www folder: ?
chmod -R a+rX www

## 4. Import mysql database
## 5. Edit .env (db) and .env (smtp + db)
