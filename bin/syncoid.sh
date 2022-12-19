#!/usr/bin/bash

# crontab -e
# CRON_TZ=UTC
# 0 19 * * *     /usr/bin/bash /home/rene/bin/syncoid.sh &>> /var/log/syncoid.log

echo -e "\n\nStarting syncoid backup: $(date +"%F @ %T")"
syncoid \
	--sshkey=/home/rene/.ssh/backup_awow \
	--recursive --sendoptions="w" \
	zroot/encr root@192.168.178.81:backup/work/encr

EXITCODE=$?
if [[ ${EXITCODE} != 0 ]]; then
	sudo -u rene DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
	/usr/bin/notify-send -u critical -i /SHARE/backup.png "Backup failed!"
	echo "Syncoid backup failed!: $(date +"%F @ %T")"

else
	sudo -u rene DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
	/usr/bin/notify-send -t 30000 -u normal -i /SHARE/backup.png "Backup completed!"
	echo "Finished syncoid backup: $(date +"%F @ %T")"
fi

exit "${EXITCODE}"
