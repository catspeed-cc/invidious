#!/usr/bin/bash

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)

# Absolute path this script is in. /home/user/bin
export SCRIPT_PATH=`dirname $SCRIPT`

cd ${SCRIPT_PATH}

. ${SCRIPT_PATH}/config.cfg

echo ""
echo "This script will install git, wget, curl, nvm and set node v20.18.0 as current version."
echo ""
echo "You have 5 seconds to quit if this is not what you want (CTRL+C)"
echo ""

sleep 5 ;

mkdir etc
mkdir logs

apt install -y git wget curl

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install v20.18.0
nvm use v20.18.0

cd ${SCRIPT_PATH}/etc/

git clone https://github.com/YunzheZJU/youtube-po-token-generator.git

cd ${SCRIPT_PATH}/etc/youtube-po-token-generator

npm install

node examples/one-shot.js

echo ""
echo "Installation complete"
echo ""
