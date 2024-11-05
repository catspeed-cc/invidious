#!/usr/bin/bash

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)

# Absolute path this script is in. /home/user/bin
export SCRIPT_PATH=`dirname $SCRIPT`

echo ""
echo "This script will install git, wget, curl, nvm and set node v20.18.0 as current version."
echo ""
echo "You have 5 seconds to quit if this is not what you want (CTRL+C)"
echo ""

sleep 5 ;

cd ${SCRIPT_PATH}/../

echo "chown and chmod the root directory"

chown -R invidious: ${SCRIPT_PATH}/../
chmod -R 770 ${SCRIPT_PATH}/../

echo ""
echo "adding invidious user"

adduser \
  --system \
  --shell /bin/bash \
  --gecos 'User for installing and running invidious' \
  --group \
  --disabled-password \
  --home /home/invidious \
  invidious

#. ${SCRIPT_PATH}/config.cfg

echo ""
echo "updating apt sources & installing dependencies"

# git is already insalled, otherwise they wouldn't even have the repository.
# just added in case the user took a tar.gz or zip
apt update
apt install -y libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev postgresql librsvg2-bin libsqlite3-dev zlib1g-dev libpcre3-dev libevent-dev fonts-open-sans
apt install -y htop git wget curl cpulimit

echo ""
echo "installing nvm under invidious user"
su - invidious -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"

echo ""
echo "installing node under invidious user"
su - invidious -c "nvm install v20.18.0"
su - invidious -c "nvm use v20.18.0"

echo ""
echo "git pull & submodule init / update"
su - invidious -c "cd ${SCRIPT_PATH}/../ ; git pull ;"
su - invidious -c "cd ${SCRIPT_PATH}/../ ; git submodule init ;"
su - invidious -c "cd ${SCRIPT_PATH}/../ ; git submodule update ;"
su - invidious -c "cd ${SCRIPT_PATH}/../ ; git submodule update --remote ;"

echo ""
echo "installing token generator dependencies"
su - invidious -c "cd ${SCRIPT_PATH}/../submodules/youtube-po-token-generator ; npm install ;"

echo ""
echo "testing token generator"
su - invidious -c "cd ${SCRIPT_PATH}/../submodules/youtube-po-token-generator ; node examples/one-shot.js ;"




# shouldnt need this because the shell closes and reopens each time you execute command as user
#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

echo ""
echo "Installation complete"
echo ""
