## Install Requirements and Activate
```
sudo apt update
sudo apt install samba ufw -y
sudo ufw allow ssh
sudo ufw allow 'Samba'
sudo ufw enable
sudo systemctl enable --now smbd
```

## Create Share Directory & Set Password
```
mkdir -p /home/your_username/shared_folder
sudo smbpasswd -a your_username
```

## Configure the Share
```
sudo tee -a /etc/samba/smb.conf > /dev/null <<EOT

[MyShare]
path = /home/your_username/shared_folder
read only = no
EOT
```

## Then restart the service to apply changes:
```
sudo systemctl restart smbd
```

## Navigate
cd /home/your_username/shared_folder
