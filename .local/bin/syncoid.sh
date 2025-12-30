#!/usr/bin/bash

# USAGE:
# ======
#
# crontab -e
# CRON_TZ=UTC
# 0 19 * * *  DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/<userid>/bus SLACK_URL=<webhook_url> /usr/bin/bash <path/to/syncoid.sh> &>> /var/log/syncoid.log
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

# uncomment only for testing!
# set -euxo pipefail
# SLACK_URL=<webhook_url>

CLIENT=$(hostnamectl hostname)
ICON_START="${HOME}/.local/share/icons/notify-send/backup.png"
ICON_SUCCESS="${HOME}/.local/share/icons/notify-send/check.png"
ICON_FAIL="${HOME}/.local/share/icons/notify-send/caution.png"

slack_notification() {
	if [ -n "${SLACK_URL}" ]; then
		local log
		local subj
		local json
		subj="*Syncoid backup from host ${CLIENT^^} failed!*"
		log="$(tail /var/log/syncoid.log)"
		# special characters must be properly escaped for valid JSON -> use jq
		# shellcheck disable=SC2016
		json="$(printf '%s\n\n```%s```' "${subj}" "${log}" | jq -Rsa)"
		curl -s -o /dev/null --json '{"text": '"${json}"'}' "${SLACK_URL}"
	fi
}

notify() {
	if [ -z "${DISPLAY}" ]; then
		return
	else
		notify-send "$@"
	fi
}

echo -e "\n\nStarting syncoid backup: $(date -u +"%F @ %T UTC")\n---"

if ! ssh "${CLIENT}@backup" 'whoami' >/dev/null 2>&1; then
	notify -u critical -i "${ICON_FAIL}" "Backup host not reachable!"
	exit
fi

notify -t 30000 -u normal -i "${ICON_START}" "Starting Backup!"
syncoid \
	--recursive \
	--sendoptions="w" \
	--no-privilege-elevation \
	--no-sync-snap \
	zroot/encr "${CLIENT}@backup:backup/${CLIENT}/encr"

EXITCODE=$?
if [ ${EXITCODE} != 0 ]; then
	notify -u critical -i "${ICON_FAIL}" "Backup failed!"
	echo -e "---\nSyncoid backup failed!: $(date -u +"%F @ %T UTC")"
	slack_notification
else
	notify -t 30000 -u normal -i "${ICON_SUCCESS}" "Backup completed!"
	echo -e "---\nFinished syncoid backup: $(date -u +"%F @ %T UTC")"
fi

exit "${EXITCODE}"
