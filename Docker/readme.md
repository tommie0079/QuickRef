# Common Docker Commands

## Images
```bash
docker pull <image>              # Download an image
docker images                    # List local images
docker rmi <image>               # Remove an image
docker build -t <name>:<tag> .   # Build image from Dockerfile
docker image prune               # Remove unused images
```

## Containers
```bash
docker run <image>                       # Run a container
docker run -d <image>                    # Run detached (background)
docker run -it <image> bash              # Run interactive with shell
docker run -p 8080:80 <image>            # Map host:container port
docker run --name <name> <image>         # Assign a name
docker run -v /host:/container <image>   # Mount a volume
docker ps                                # List running containers
docker ps -a                             # List all containers
docker stop <container>                  # Stop a container
docker start <container>                 # Start a stopped container
docker restart <container>               # Restart a container
docker rm <container>                    # Remove a container
docker container prune                   # Remove all stopped containers
```

## Interaction
```bash
docker exec -it <container> bash   # Open shell in running container
docker logs <container>            # View container logs
docker logs -f <container>         # Follow logs live
docker inspect <container>         # Show detailed info
docker stats                       # Live resource usage
docker cp <container>:/path ./     # Copy files from container
```

## Docker Compose
```bash
docker compose up            # Start services
docker compose up -d         # Start detached
docker compose down          # Stop and remove services
docker compose ps            # List services
docker compose logs -f       # Follow logs
docker compose build         # Build/rebuild services
docker compose restart       # Restart services
```

## Volumes & Networks
```bash
docker volume ls             # List volumes
docker volume create <name>  # Create a volume
docker volume rm <name>      # Remove a volume
docker network ls            # List networks
docker network create <name> # Create a network
```

## System / Cleanup
```bash
docker system df             # Show disk usage
docker system prune          # Remove unused data
docker system prune -a       # Remove all unused images too
docker info                  # System-wide info
docker version               # Docker version
```
