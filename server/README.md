# Instructions and Commands to prepare for Docker Volumes

## Prepare for Volume

1. Check containers are running

```
docker ps -a
```

2. Copy files from MariaDB Container into current directory

```
docker cp cnt-db:C:\mariadb\data .
```

3. Rename copied directory

```
Rename-Item data mariadb-data
```

4. Copy files from Wordpress Container into current directory

```
docker cp cnt-wordpress:C:\Apache\htdocs .
```

5. Rename copied directory

```
Rename-Item htdocs wordpress-data
```

6. Uncomment volumes section in docker-compose file

7. Create and run containers from docker-compose file

```
docker-compose up -d
```
