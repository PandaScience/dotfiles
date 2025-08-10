#!/usr/bin/bash

# add to crontab:
# CRON_TZ=UTC
# 0 12 * * *  SLACK_URL=<webhook_url> /usr/bin/bash <path/to/script.sh>

# requires SLACK_URL to be set in /etc/environment or uncomment below
# SLACK_URL=<webhook_url>

if command -v hostname >/dev/null; then
	CLIENT=$(hostname)
elif command -v hostnamectl >/dev/null; then
	CLIENT=$(hostnamectl hostname)
fi

POOLS=$(zpool list -H -o name)
TRESHOLD=80

for p in $POOLS; do
	cap=$(zpool list -H -o cap "${p}" | tr -d "%")
	if ((cap > TRESHOLD)); then
		status=$(zpool list "${p}")
		subj="Low space on host \`${CLIENT}\` in pool \`${p}\` !"
		# shellcheck disable=SC2016  # single quotes required for proper JSON
		json=$(printf '*%s*\n```%s```' "${subj}" "${status}" | jq -Rsa)
		curl -s -o /dev/null -H "Content-Type: application/json" -X POST \
			-d '{"text": '"${json}"'}' "${SLACK_URL}"
	fi
done
