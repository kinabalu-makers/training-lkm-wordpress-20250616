# training-lkm-wordpress-20250616
Training Sample Docker Builds and Compose Files

## Docker Commands Cheatsheet

| Command                              | Description                                 |
|---------------------------------------|---------------------------------------------|
| `docker build . -t <name>`            | Build an image from a Dockerfile            |
| `docker images`                       | List all local images                       |
| `docker run <image>`                  | Run a container from an image               |
| `docker ps`                           | List running containers                     |
| `docker ps -a`                        | List all containers (including stopped)     |
| `docker stop <container>`             | Stop a running container                    |
| `docker start <container>`            | Start a stopped container                   |
| `docker rm <container>`               | Remove a container                          |
| `docker rmi <image>`                  | Remove an image                             |
| `docker exec -it <container> bash`    | Run a bash shell inside a running container |
| `docker logs <container>`             | View logs from a container                  |
| `docker compose up`                   | Start services defined in docker-compose    |
| `docker compose down`                 | Stop and remove docker-compose services     |
| `docker compose build`                | Build images defined in docker-compose      |
