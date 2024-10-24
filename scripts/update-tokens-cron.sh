#!/usr/bin/bash

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)

# Absolute path this script is in. /home/user/bin
export SCRIPT_PATH=`dirname $SCRIPT`

cd ${SCRIPT_PATH}/etc/

#. ${SCRIPT_PATH}/config.cfg

ITU_LOG_FILE=logs/tokens.log

touch ${SCRIPT_PATH}/${ITU_LOG_FILE}

update_tokens () {

echo "" | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}
echo "Generating visitordata & potoken..." | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}
echo ""

# THIS IS THE ACTUAL COMMAND, WILL TAKE TIME TO PROCESS
#rawOutput=$(export http_proxy=127.0.0.1:800${1} ; export http_proxy=127.0.0.1:800${1} ; sudo docker run --rm quay.io/invidious/youtube-trusted-session-generator)
if [ ! -z "${3}" ] ; then
  rawOutput=$(export http_proxy=${3} ; export http_proxy=${3} ; ${HOME}/.nvm/versions/node/v20.18.0/bin/node ${SCRIPT_PATH}/etc/youtube-po-token-generator/examples/one-shot.js)
else
  rawOutput=$(${HOME}/.nvm/versions/node/v20.18.0/bin/node ${SCRIPT_PATH}/etc/youtube-po-token-generator/examples/one-shot.js)
fi

#echo "RAWOUTPUT: \"${rawOutput}\""
#echo "RAWOUTPUT2: \"${rawOutput2}\""

# EXTRACT THE TOKENS
#VISITORDATA=$(echo ${rawOutput} | sed -n "s/^.*visitor_data:\s*\(\S*\).*$/\1/p")
#POTOKEN=$(echo ${rawOutput} | sed -n "s/^.*po_token:\s*\(\S*\).*$/\1/p")

# EXTRACT THE TOKENS
VISITORDATA=$(echo ${rawOutput} | awk -F"'" '/visitorData/{print $2}')
POTOKEN=$(echo ${rawOutput} | awk -F"'" '/poToken/{print $4}')

# DISPLAY TO $USER
echo "po_token: \"${POTOKEN}\""
echo "visitor_data: \"${VISITORDATA}\""

# DISPLAY TO $USER
#echo "po_token2: \"${POTOKEN2}\""
#echo "visitor_data2: \"${VISITORDATA2}\""

# MAKE THE CONFIGURATION MODIFICATIONS

TSTAMP=$(date +"[%D][%T]")

echo ""
echo "${TSTAMP} Editing invidious config file ${1}" | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}

sed -i 's/^.*po_token.*/po_token: \"'${POTOKEN}'\"/g' ${1}
sed -i 's/^.*visitor_data.*/visitor_data: \"'${VISITORDATA}'\"/g' ${1}

if [ ! -z "${2}" ]; then
echo ""
echo "${TSTAMP} NOT Restarting service ${2}${1}" | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}
/usr/sbin/service ${2} restart
fi

echo ""
echo "Random search to wake up YT ${SCRIPT_PATH}/etc/searches.txt"
echo ""
TSTAMP=$(date +"[%D][%T]")
YT_QUERY=$(shuf -n 1 ${SCRIPT_PATH}/etc/searches.txt)
YT_QUERY=${YT_QUERY//[$'\t\r\n']}
YT_QUERY=${YT_QUERY// /+}
echo "Querying for '${YT_QUERY}'"

if [ ! -z "${3}" ] ; then
curl -s --proxy "${3}" "https://www.youtube.com/results?search_query=${YT_QUERY}" >/dev/null
else
curl -s "https://www.youtube.com/results?search_query=${YT_QUERY}" >/dev/null
fi
echo "${TSTAMP} YT_QUERY: \"${YT_QUERY}\"" | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}

# ECHO THE TOKENS TO LOGFILE
TSTAMP=$(date +"[%D][%T]")
echo ""
echo "${TSTAMP} UPDATED TOKENS ${2}${1}!" | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}
echo "${TSTAMP} po_token: \"${POTOKEN}\"" | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}
echo "${TSTAMP} visitor_data: \"${VISITORDATA}\"" | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}

}

TSTAMP=$(date +"[%D][%T]")
echo "" | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}
echo "${TSTAMP} CRON RUNNING ${2}${1}" | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}
#echo "" | tee -a ${3}

update_tokens "${1}" "${2}" "${3}"

#update_tokens "/full/path/to/invidious/config.yml" "invidious-service-name-1" "http://127.0.0.1:8001"

TSTAMP=$(date +"[%D][%T]")
echo "" | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}
echo "${TSTAMP} CRON FINISHED ${2}${1}" | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}
#echo "" | tee -a ${SCRIPT_PATH}/${ITU_LOG_FILE}

echo ""
echo "Done. Have a good day :)"
echo ""
