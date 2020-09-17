#!/bin/bash
# LinuxGSM alert_rocketchat.sh function
# Author: Alasdair Haig
# Website: https://linuxgsm.com
# Description: Sends Rocketchat alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if ! command -v jq > /dev/null; then
	fn_print_fail_nl "Sending Rocketchat alert: jq is missing."
	fn_script_log_fatal "Sending Rocketchat alert: jq is missing."
fi

json=$(cat <<EOF
{
	"alias": "LinuxGSM",
	"text": "*${alertemoji} ${alertsubject} ${alertemoji}* \n *${servername}* \n ${alertbody}",
	"attachments": [
		{
			"fields": [
				{
					"short": true,
					"title": "Game:",
					"value": "${gamename}"
				},
				{
					"short": true,
					"title": "Server IP:",
					"value": "${alertip}:${port}"
				}
			]
		}
	]
	"text": "Hostname: ${HOSTNAME} / More info: ${alerturl}",
}
EOF
)

fn_print_dots "Sending Rocketchat alert"

rocketlaunch=$(curl -sSL -H "Content-Type:application/json" -X POST -d "$(echo -n "$json" | jq -c .)" "${rocketchatwebhook}")

if [ "${rocketlaunch}" == "ok" ]; then
	fn_print_ok_nl "Sending Rocketchat alert"
	fn_script_log_pass "Sending Rocketchat alert"
else
		fn_print_fail_nl "Sending Rocketchat alert: ${rocketlaunch}"
	fn_script_log_fatal "Sending Rocketchat alert: ${rocketlaunch}"
fi
