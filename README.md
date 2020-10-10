![Build](https://github.com/0xERR0R/bitwarden-backup-docker/workflows/Build/badge.svg)

# Paranoid bitwarden backup

Creates backup of bitwarden_rs data for paranoid people (like me). The backup file contain:

- bitwarden_rs attachments directory
- bitwarden_rs sqllite database file
- sql dump of sqllite (in case sqllite is corrupt)
- plain text (!) export of user passwords (as JSON) and attachments (multiple user supported)

**NOTE:** BE AWARE: You have to define username and password as environment variable -> all passwords will be exported as plain text. Backup file is protected by defined password (Zip) -> this is **NOT** secure. Use this backup only in protected local network!!!

Bitwarden data should be under `/data`

| Variable        | Example             | Description                                              |
|-----------------|---------------------|----------------------------------------------------------|
| BITWARDEN_URL   | https://example.com | Bitwarden url                                            |
| BACKUP_PASSWORD | passw0rd!           | Use this password to encrypt the backup archive          |
| BW_USER_XXX     | admin               | Name of the user (XXX can be replaced with some string)  |
| BW_PASSWORD_XXX | passw0r!            | Corresponding password                                   |

## Complete example with docker-compose

create backup.env with following content:

```bash
BACKUP_PASSWORD=xxx
BW_USER_1=xxx
BW_PASSWORD_1=xxx
BW_USER_2=xxx
BW_PASSWORD_2=xxx
```

Following `docker-compose.yml` starts bitwarden and bitwarden-backup. Backup file will be stored in a volume "backup" which is mounted via samba (NAS). Backup will run only on startup. You should trigger the execution per cron `docker-compose run backup` or by using of external tools like [ofelia](https://github.com/mcuadros/ofelia). You can also use this image as a Kubernetes CronJob.

```yaml
version: '2.1'
services:
   bitwarden:
      image: bitwardenrs/server:latest
      restart: unless-stopped
      container_name: bitwarden
      volumes:
         - bitwarden:/data/
      environment:
         - TZ=Europe/Berlin
         - EXTENDED_LOGGING=false
         - ROCKET_LOG=critical
   backup:
      image: spx01/bitwarden-backup
      env_file: 
      - backup.env
      environment:
      - BITWARDEN_URL=http://bitwarden:80
      container_name: bitwarden_backup
      depends_on:
      - bitwarden      
      volumes:
      - backup:/out
      volumes_from:
      - bitwarden
volumes:
   bitwarden:
   backup:
      driver: local
      driver_opts:
        type: cifs
        o: username=XXX,password=XXX,rw
        device: //IP/apath/to/backup/directory
```

Credits: Thanks to `ckabalan` for the attachment export: https://github.com/ckabalan/bitwarden-attachment-exporter
