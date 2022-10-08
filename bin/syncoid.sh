#!/usr/bin/bash

# crontab -e
# 1 21 * * *     /usr/bin/bash /home/rene/bin/syncoid.sh &>> /var/log/syncoid.log

echo -e "\n\nStarting syncoid backup: $(date +"%F @ %T")"
syncoid \
	--sshkey=/home/rene/.ssh/backup_awow \
	--recursive --sendoptions="w" \
	zroot/encr root@192.168.178.81:backup/work/encr
echo "Finished syncoid backup: $(date +"%F @ %T")"
