# ProFTPD: SFTP Configured
A simple Configured SFTP ProFTPD Server with virtual users (Not using system users).

## Usage
### Basic
```bash
docker run -d --name sftp -p 2222:2222 librasoftfr/proftpd-sftp
```

### Persistent data
To persist data you should mount **/data** folder and **/etc/proftpd/sftp** folder.
- In **/data** you will find uploaded files 
- In **/etc/proftpd/sftp** you will find ftppassw and ftpgroup for virtuals users, authorized_keys and generated SSH hosts keys.
```bash
docker run -d --name sftp -p 2222:2222 -v $(pwd)/mydata:/data -v $(pwd)/config:/etc/proftpd/sftp librasoftfr/proftpd-sftp
```

### With a compose file
Two compose files are provided : 
- compose-dev.yml : This is for building the image from the Dockerfile in local.
- compose-prod.yml : This is the file to use for production using the official image from Docker Hub.

If you use the production file, just keep the compose-prod.yml and the Makefile for easier commands.
```yaml
services:
  sftp:
    container_name: sftp
    image: librasoftfr/proftpd-sftp:latest
    restart: always
    networks:
      - default
    volumes:
      - ./mydata:/data
      - ./config:/etc/proftpd/sftp
    ports:
      - ${SFTP_PORT:-2222}:2222
    environment:
      - SFTP_AUTH_METHODS=${SFTP_AUTH_METHODS:-password}
      - SFTP_TZ=${SFTP_TZ:-Europe/Paris}
      - SFTP_MAX_INSTANCES=${SFTP_MAX_INSTANCES:-30}
      - SFTP_TIMEOUT_NO_TRANSFER=${SFTP_TIMEOUT_NO_TRANSFER:-600}
      - SFTP_TIMEOUT_STALLED=${SFTP_TIMEOUT_STALLED:-600}
      - SFTP_TIMEOUT_IDLE=${SFTP_TIMEOUT_IDLE:-1200}
```

## Create a user/group
### Legacy method
User/group can be created with ftpasswd(proftpd-utils) on running container.
Location of the ftppasswd/ftpgroup is presented in the example below.

    docker exec -ti sftp ftpasswd --passwd --file=/etc/proftpd/sftp/ftppasswd --name user1 --uid=1000 --gid=1000 --home=/data/user1 --shell=/sbin/nologin
    docker exec -ti sftp ftpasswd --group --file=/etc/proftpd/sftp/ftpgroup --name=siteuser --gid=1000

Because of setting with "DefaultRoot ~", user home directory will be chroot'ed. The data directory to be used must be mounted.

### Easy method
But to make it more easier, you can use our **make** command :
```bash
make create-user myusername myhomepath
```

You can check others commands just with : 
```bash
make

Usage: make <command> [args]

Commands:
  create-user <username> <dir>     - Creates a user with specified username and home directory (should start with a /).
  list-users                       - List all currently configured users.
  delete-user <username>           - Delete the specified user.
  delete-all-users                 - Delete all currently configured users.
  connect                          - Connect to the container.
  build-and-push-images <version>  - Build image and push images on docker hub.
  help                             - Displays this help message.
```

## Customize
### Environment Variables
- SFTP_TZ
  - Timezone(ex. Europe/Paris) (optional)
- SFTP_AUTH_METHODS
  - SFTPAuthMethods(publickey, password, or publickey+password) (default:publickey) (optional)
- SFTP_MAX_INSTANCES
  - The MaxInstances directive configures the maximum number of child (session) processes that may be spawned by the proftpd daemon process when running with "ServerType standalone" configured. The directive has no effect when proftpd is configured with "ServerType inetd".
- SFTP_TIMEOUT_NO_TRANSFER
  - The TimeoutNoTransfer directive configures the maximum number of seconds a client is allowed to spend connected, after authentication, without issuing a data transfer command which results in a data connection (i.e. sending/receiving a file, or requesting a directory listing). The maximum allowed seconds value is 65535 (18 hours).
- SFTP_TIMEOUT_STALLED
  - The TimeoutStalled directive sets the maximum number of seconds a data connection between proftpd and a client can exist but have no actual data transferred (i.e. "stalled"). If the seconds parameter is set to zero, data transfers are allowed to stall indefinitely; note that this is not a recommended configuration. The maximum allowed seconds value is 65535 (18 hours).
- SFTP_TIMEOUT_IDLE
  - The TimeoutIdle directive configures the maximum number of seconds that proftpd will allow clients to stay connected without receiving any data on either the control or data connection. If data are received on either connection, the idle timer is reset. Setting TimeoutIdle to zero disables the idle timer completely, meaning that clients can stay connected forever, without sending data. Note: this is generally a very bad idea, as a "hung" TCP connection which is never properly disconnected (e.g. the remote network may have become disconnected from the Internet, etc) will cause a session process to never exit, until manually killed. This session process will thus linger, using up one of the MaxInstances as well as any of the other configured limits. The maximum allowed seconds value is 65535 (18 hours).

### Configuration file
If you want modify configuration file(s), mount your file to these places.

- sftp.conf -- /etc/proftpd/conf.d/sftp.conf
- proftpd.conf -- /etc/proftpd/proftpd.conf

## Prerequisites
In order to use this project you need : 

### "Docker Engine" 
Follow this guide for installation : https://docs.docker.com/engine/install/

### "Make package"
Depending of your Linux Distributions execute the related command :

#### **Ubuntu / Debian**
```bash
sudo apt update && sudo apt install make
```
#### **Fedora**
```bash
sudo dnf install make
```
#### **CentOS / RHEL**
```bash
sudo yum install make
```
For CentOS 8 or RHEL 8, use:
```bash
sudo dnf install make
```
#### **Arch Linux**
```bash
sudo pacman -S make
```
#### **openSUSE**
```bash
sudo zypper install make
```
#### **Alpine Linux**
```bash
sudo apk add make
```

## Authors
- [@librasoft-fr](https://github.com/librasoft-fr)

## License
[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)

## Support
For support, don't hesitate to contact us on [https://librasoft.fr/](https://librasoft.fr/#contact).
