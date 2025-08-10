#!/usr/bin/bash

# requires SLACK_URL to be set in /etc/environment or uncomment below
# SLACK_URL=<webhook_url>
#
# needs extra invitation b/c started by systemd unit
source /etc/environment

if command -v hostname >/dev/null; then
	CLIENT=$(hostname)
elif command -v hostnamectl >/dev/null; then
	CLIENT=$(hostnamectl hostname)
fi

subj="S.M.A.R.T Daemon error on host \`${CLIENT^^}\`: \`${SMARTD_FAILTYPE}\`"
# shellcheck disable=SC2016  # single quotes required for proper JSON
json=$(printf '*%s* \n%s ```%s```' "${subj}" "${SMARTD_MESSAGE}" "${SMARTD_FULLMESSAGE}" | jq -Rsa)
curl -s -o /dev/null -H "Content-Type: application/json" -X POST \
	-d '{"text": '"${json}"'}' "${SLACK_URL}"
