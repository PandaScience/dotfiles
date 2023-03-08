#!/usr/bin/bash

# crontab -e
# CRON_TZ=UTC
# 0 19 * * *     /usr/bin/bash /home/rene/bin/syncoid.sh &>> /var/log/syncoid.log
#
# ~/.ssh/config
#
# Host backup
#   HostName <IP>
#   IdentityFile <backup-ssh-key>
#   User <local_hostname>
#
# Logging:
#   touch /var/log/syncoid.log
#   chown root:wheel /var/log/syncoid.log
#   chmod ug+rw /var/log/syncoid.log

CLIENT=$(hostname)

echo -e "\n\nStarting syncoid backup: $(date +"%F @ %T")\n---"
notify-send -t 30000 -u normal -i /SHARE/backup.png "Starting Backup!"
syncoid \
	--recursive \
	--sendoptions="w" \
	--no-privilege-elevation \
	--no-sync-snap \
	zroot/encr ${CLIENT}@backup:backup/${CLIENT}/encr

EXITCODE=$?
if [[ ${EXITCODE} != 0 ]]; then
	notify-send -u critical -i /SHARE/backup.png "Backup failed!"
	echo -e "---\nSyncoid backup failed!: $(date +"%F @ %T")"

else
	notify-send -t 30000 -u normal -i /SHARE/backup.png "Backup completed!"
	echo -e "---\nFinished syncoid backup: $(date +"%F @ %T")"
fi

exit "${EXITCODE}"
