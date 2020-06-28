# LEMP stack with Supervisor
Docker container containing a webserver and php-fpm supervised by (you guessed it) supervisor. 
Used for running multiple websites locally in a development setup.

## Creating the image
create the docker image locally:
```
git clone https://github.com/hanwoolderink88/docker-nginx-php7.4-supervisor 
cd docker-nginx-php7.4-supervisor
docker build -t hanwoolderink/lemp:latest .
```
or download it from docker hub:
```
docker pull hanwoolderink/lemp:latest
``` 

## Running the container
Im running it with docker-compose the setup with the following files:
```
- docker-compose.yml
- sites-available.conf
- projects
  - google.com
  - facebook.com
``` 
where the projects directory holds all the sites/apps roots. I've been using it for wordpress sites as the exampole site-available.conf will reflex. In this docker-compose setup it is basically an overwrite of all server stanza's in (nginx) so any setup will do. 

docker-compose.yml
```
version: "3.7"
services:
  web:
    image: hanwoolderink/lemp:latest
    ports:
    - 80:80
    - 443:443
    volumes:
    - ./projects:/var/www/projects
    - ./sites-available.conf:/etc/nginx/sites-available/default
```

sites-available.conf
```
#http redirect to https
server {
    listen             80 default_server;
    server_name        _;
    return             301 https://$host$request_uri;
}

# default root
server {
    server_name         _;
    root                /var/www/base/public;
    include             snippets/wordpress-single.conf;
}

server {
    server_name         google.com;
    root                /var/www/projects/google.com;
    include             snippets/wordpress-single.conf;
}

server {
    server_name         facebook.com;
    root                /var/www/projects/facebook.com;
    include             snippets/wordpress-single.conf;
}
```