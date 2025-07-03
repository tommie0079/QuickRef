# Notes

## 1 Get tunnel token

### Add domain

1. [Login Cloudflared](https://dash.cloudflare.com/login)
2. Click `+ Add a domain` and follow instructions


### 2 Create tunnel

1. Click Zero trust -> Networks -> Tunnels
2. Create tunnel -> Docker -> Get the token, its behind --token. Keep it save we are going to use it later. 
3. Click next, select domain. Service: Type HTTP. URL: localhost:<port>, we are using port 3000.   


## 1. Install docker Ubuntu
[Setup](https://docs.docker.com/engine/install/ubuntu/)

## 2. Git 

### git install
```
sudo apt install git-all
```

### git clone 
```
git clone https://github.com/tommie0079/QuickRef.git
```

## Setup

```
cd QuickRef -> cd Cloudflared
```

### make .env
```
nano .env
```

### .env file content
``` 
TOKEN=your token from cloudflared website
```

### docker compose 

```
docker compose up -d
```

### docker status 
```
docker ps
```


## Troubleshooting
```
docker logs <Container name>
```