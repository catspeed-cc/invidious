# Notice

You are currently on the development branch. This branch is unstable, and at times, may not compile.

To switch to more stable master branch, ```git checkout master``` and ```git pull```

------
<div align="center">
  <img src="assets/invidious-colored-vector.svg" width="192" height="192" alt="Invidious logo">
  <h1>Invidious</h1>

  <a href="https://www.gnu.org/licenses/agpl-3.0.en.html">
    <img alt="License: AGPLv3" src="https://shields.io/badge/License-AGPL%20v3-blue.svg">
  </a>
  <a href="https://github.com/iv-org/invidious/actions">
    <img alt="Build Status" src="https://github.com/iv-org/invidious/workflows/Invidious%20CI/badge.svg">
  </a>
  <a href="https://github.com/iv-org/invidious/commits/master">
    <img alt="GitHub commits" src="https://img.shields.io/github/commit-activity/y/iv-org/invidious?color=red&label=commits">
  </a>
  <a href="https://github.com/iv-org/invidious/issues">
    <img alt="GitHub issues" src="https://img.shields.io/github/issues/iv-org/invidious?color=important">
  </a>
  <a href="https://github.com/iv-org/invidious/pulls">
    <img alt="GitHub pull requests" src="https://img.shields.io/github/issues-pr/iv-org/invidious?color=blueviolet">
  </a>
  <a href="https://hosted.weblate.org/engage/invidious/">
    <img alt="Translation Status" src="https://hosted.weblate.org/widgets/invidious/-/translations/svg-badge.svg">
  </a>

  <a href="https://github.com/humanetech-community/awesome-humane-tech">
    <img alt="Awesome Humane Tech" src="https://raw.githubusercontent.com/humanetech-community/awesome-humane-tech/main/humane-tech-badge.svg?sanitize=true">
  </a>

  <h3>An open source alternative front-end to YouTube</h3>

  <a href="https://invidious.io/">Website</a>
  &nbsp;•&nbsp;
  <a href="https://instances.invidious.io/">Instances list</a>
  &nbsp;•&nbsp;
  <a href="https://docs.invidious.io/faq/">FAQ</a>
  &nbsp;•&nbsp;
  <a href="https://docs.invidious.io/">Documentation</a>
  &nbsp;•&nbsp;
  <a href="#contribute">Contribute</a>
  &nbsp;•&nbsp;
  <a href="https://invidious.io/donate/">Donate</a>
 <center>
    <a href="https://catspeed.cc/donate/">Donate to catspeed.cc</a>
    &nbsp;•&nbsp;
    <a href="https://pr.tn/ref/04PN5S3WMGBG">Get ProtonVPN</a>
 </center>

  <h5>Chat with us:</h5>
  <a href="https://matrix.to/#/#invidious:matrix.org">
    <img alt="Matrix" src="https://img.shields.io/matrix/invidious:matrix.org?label=Matrix&color=darkgreen">
  </a>
  <a href="https://web.libera.chat/?channel=#invidious">
    <img alt="Libera.chat (IRC)" src="https://img.shields.io/badge/IRC%20%28Libera.chat%29-%23invidious-darkgreen">
  </a>
  <br>
  <a rel="me" href="https://social.tchncs.de/@invidious">
  <img alt="Fediverse: @invidious@social.tchncs.de" src="https://img.shields.io/badge/Fediverse-%40invidious%40social.tchncs.de-darkgreen">
  </a>
  <br>
  <a href="https://invidious.io/contact/">
  <img alt="E-mail" src="https://img.shields.io/badge/E%2d%2dmail-darkgreen">
  </a>
</div>


## Screenshots

| Player                              | Preferences                         | Subscriptions                         |
|-------------------------------------|-------------------------------------|---------------------------------------|
| ![](screenshots/01_player.png)      | ![](screenshots/02_preferences.png) | ![](screenshots/03_subscriptions.png) |
| ![](screenshots/04_description.png) | ![](screenshots/05_preferences.png) | ![](screenshots/06_subscriptions.png) |


## Features

**Patches**
- revert [d9df90b5e3ab6f738907c1bfaf96f0407368d842](https://github.com/catspeed-cc/invidious/commit/d9df90b5e3ab6f738907c1bfaf96f0407368d842)
- add redis patch
- add proxy patch
- sig helper reconnect patch
- freshtokens (mooleshacat)
- csp hack patch (mooleshacat)
- uptime status (mooleshacat)
- loadavg status (mooleshacat)
- enable/disable catspeed branding (mooleshacat)
- enable/disable catspeed, invidious donate link (mooleshacat)
- custom status page, issue tracker, freetube help, donation links (mooleshacat)

**User features**
- Lightweight
- No ads
- No tracking
- No JavaScript required
- Light/Dark themes
- Customizable homepage
- Subscriptions independent from Google
- Notifications for all subscribed channels
- Audio-only mode (with background play on mobile)
- Support for Reddit comments
- [Available in many languages](locales/), thanks to [our translators](#contribute)

**Data import/export**
- Import subscriptions from YouTube, NewPipe and Freetube
- Import watch history from YouTube and NewPipe
- Export subscriptions to NewPipe and Freetube
- Import/Export Invidious user data

**Technical features**
- Embedded video support
- [Developer API](https://docs.invidious.io/api/)
- Does not use official YouTube APIs
- No Contributor License Agreement (CLA)

**Support**
- create a support ticket here https://gitea.catspeed.cc/catspeed-cc/invidious/issues
- please do not create tickets elsewhere.


## Quick start

**Using invidious:**

- [Select a public instance from the list](https://instances.invidious.io) and start watching videos right now!

**Hosting invidious:**

- You will need a default redis install ```apt install -y redis-server```
- You still need postgresql
- You still need sighelper
- You still need to figure out how to update the tokens in config file (with bash script or otherwise)
- Invidious will automatically reload the tokens from the config file every 1 minute
- [Follow the installation instructions](https://docs.invidious.io/installation/)

**Notice to instance owners:**

It appears the working solution currently is to use:
- sig helper
- po_token & visitor_data
- a VPN proxy (privoxy, proton-privoxy, etc.)

I personally use proton VPN, you can get it along with your email here: https://pr.tn/ref/04PN5S3WMGBG - if you want VPN only you can try to get it there or just go to https://protonvpn.com . You can get a working proton-privoxy from https://github.com/catspeed-cc/proton-privoxy .

I use one invidious instance, one sig helper, and one proton-privoxy per core. Each connection to nginx is routed to the least connected backend (currently I have 4) . If you only have 1 core, use 2 processes so you can restart one at a time, minimizing downtime. I hope this is helpful to instance owners having troubles.

Public and private instance owners: if you need help with anything, create an issue ticket here: https://gitea.catspeed.cc/catspeed-cc/invidious/issues - I do not mind, I will try and help best I can.


## inv_sig_helper notes

You will need an installation of sig helper. https://github.com/catspeed-cc/inv_sig_helper or https://github.com/iv-org/inv_sig_helper will do fine. I personally set up miltiple sig helpers, one for each process. Sometimes it will crash and you need to make a crontab entry to restart inv_sig_helper and invidious. You will notice the processer usage and memory usage spike now and then. You can control that with service file cpu limits.


## redis patch notes

You will need a default installation of redis-server ```apt install -y redis-server```

_You still need postgresql. If you've followed the installation instructions it should still be there. Do not uninstall it._


## proxy patch notes

There is proxy support in this version. You may use privoxy, or any proxy. If you have proton vpn you can use https://github.com/catspeed-cc/proton-privoxy. The walterl fork https://github.com/walterl/proton-privoxy does not have a line in the config increasing the max connections or an installer script so maybe use mine.

Keep in mind especially on ProtonVPN if you restart a container, you will temporarily have 1 extra connection. So if you have 10 connections allowed, I would keep a few extra available in case a container needs restarting. I am not sure how long it takes for the stale connection to fix itself.

Restarting container (or changing servers) more than 1 time per hour can cause problems. Especially if you use 4-6 connections/containers.

I'll just leave this here https://pr.tn/ref/04PN5S3WMGBG


## uptime & loadavg status notes

This branch has the uptime & loadavg patch from myself (mooleshacat) which if enabled in the config, will show the uptime and/or loadavg on the page. Please note, if everyone can see your uptime or loadavg, so could a theoretical attacker. This may or may not be a good idea, you be the judge.


## csp hack patch notes

CSP hack changes the *c*ontent *s*ecurity *p*olicy from "'self'" to "http://mydomain.com https://*.mydomain.com". Only enable this if you have CSP errors when you inspect the video watch page (ctrl + shift + i)


## freshtokens patch notes

This branch has the freshtokens patch from myself (mooleshacat) which if not disabled in config file will automatically generate identities for logged in users, as well as anonymous users. The challenge with anonymous users is having some kind of unique identifier to assign a user an identity. How this is currently implemented is there is an identity pool from which identities are picked. Provided the pool is large enough there should not be many identity collisions. Logged in users are assigned their own identities for each instance and will experience less problems. Busy instances will need larger pools, whereas private instances should be fine with smaller pools.

Most important step when upgrading is installing dependencies. Currently the dependency installer script is not working, so you have to manually install dependencies:
- ```apt install libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev postgresql librsvg2-bin libsqlite3-dev zlib1g-dev libpcre3-dev libevent-dev fonts-open-sans```
- ```apt install htop git wget curl cpulimit redis-server```
- ```curl -fsSL https://crystal-lang.org/install.sh | sudo bash```
- ```adduser --system --shell /bin/bash --gecos 'User for installing and running invidious' --group --disabled-password --home /home/invidious invidious```
- ```su - invidious```
- ```cd ~```
- ```curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash```
- ```nvm install v20.18.0```
- ```nvm use v20.18.0```
- ```git clone --recurse-submodules https://github.com/catspeed-cc/invidious```
- ```cd invidious```
- ```npm install```
- ```cd submodules/youtube-po-token-generator```
- ```node examples/one-shot.js```
- If all goes well, you should see the mysterious tokens


Once installed, you will be able to control freshtokens with config variables. Currently they include:
- freshtokens_enabled - true/false - enables and disables freshtokens.
- freshtokens_show_ic_enabled - true/false - enables showing identity stats
- freshtokens_identserver_enabled - false/true - enables identity server (does nothing yet ...)
- freshtokens_identserver_address - "https://my.ident.server.com/ident/" - URL of identity server (does nothing yet ...)
- freshtokens_instanceid - "instance1" - a unique identifier for the instance
- freshtokens_user_expiry - 3600 - How often to expire/generate user identity
- freshtokens_anonpool_expiry: 21600 - How often to expire/generate anon identity
- freshtokens_anonpool_size: 500 - How many identities to generate

**General notes:** Identities will take time to generate. If you change the pool size higher, it may take time to generate the identities. If you ask too many identities of your server, it may not have the power to generate them. The user however will not see much effect from this. Hopefully you'd have enough identities for the users you have. In the stats, "igr" refers to the identity generation rate. The igr is a rate of change, which can be positive or negative. Positive means it is adding identities, while negative means identities are expiring. igr of 0/min simply means you are adding as many identities as are expiring. Currently catspeed is set to generate 2500 identities, with a 12 hour expiry (subject to change) - for reference, catspeed is a 4-core server with 4gb memory, which runs two invidious instances.

If you experience 403 session expired or other errors, try increasing the identity pool. If you can't generate enough identities within the expiry window, then try increasing the expiry window.

Once you finally reach the maximum identities, I would recommend switching VPN IP's because you will have accumulated enough errors to have gotten the IP temporarily banned. This typically is indicated by many "this helps protect our community" errors. A few of these is normal, but having every single user over 5 minutes getting this message signals you should either restart sig-helper, and/or try to change the VPN ip.

**For public instances:** If you are as busy as catspeed is blessed to be, you will need a identity pool of at least 2500 and I would even try for higher. I would start with an anon identity expiry of 6 hours, and depending on whether you can get up to the max identities, you can increase or decrease the identity pool and expiry. You can also adjust the expiry of identities of signed in users. I typically have a longer expiry for anon users, and a shorter expiry for signed in users.

Eventually I will make an "identity server" which can be set up on another server, specifically for generating identities. This will allow you to have a reverse proxy to a theoretically infinite number of identity servers. 

**For private instance owners:** If you only have yourself and/or a few friends on your instance, you could probably get away with an identity pool of 500, expiring every 3 hours. I would set the user expiry to 900 seconds for privacy.

This patch is a temporary workaround until inv_sig_helper itself can get the tokens for us. unixfox (invidious dev) raised this idea to techmetx11 (inv_sig_helper dev) and they are working on an implementation that will eventually make this patch useless. This is OK, as it is only a patch and that setup would be better performance wise than my current implementations. You can read about it here https://github.com/iv-org/inv_sig_helper/issues/10


## branding, status link, freetube help link & donation link notes

You can change in the config:
- enable/disable catspeed branding
- enable/disable catspeed donation link (please think of cat :3c)
- enable/disable invidious donation link (please ... invidious :3c)
- enable/disable custom donation link
- custom donation link text & url
- custom issue tracker link text & url
- custom status page link text & url
- custom freetube help page link text & url

_You need to restart the service for these to take effect._


## gitea.catspeed.cc

The repository on GitHub is now a mirror of https://gitea.catspeed.cc/catspeed-cc/invidious. The repository is updated every 60 minutes if my virtual machine is on and there are changes. There is no need to clone the repository at gitea.catspeed.cc.

For support, you can not submit any tickets on github as I've closed the issue tickets page. You can however create an account and submit an issue ticket here https://gitea.catspeed.cc/catspeed-cc/invidious/issues


## upgrading

So you noticed some recent commits to master, how do you update?
- Go into the git repo directory
- Checkout the version you want ```git checkout master```
- Pull the new changes ```git pull```
- Make the binary ```make -j<numcores>``` (replace <numcores> with your number of cores minus 1)
- If the binary exists in a different location, copy the new one over top of it
- Backup your existing config file
- Either re-copy the config.example.yml (recommended) or carefully look for the new options and add them to your config.yml (not recommended)


## Documentation

The full documentation can be accessed online at https://docs.invidious.io/

The documentation's source code is available in this repository:
https://github.com/iv-org/documentation

### Extensions

We highly recommend the use of [Privacy Redirect](https://github.com/SimonBrazell/privacy-redirect#get),
a browser extension that automatically redirects Youtube URLs to any Invidious instance and replaces
embedded youtube videos on other websites with invidious.

The documentation contains a list of browser extensions that we recommended to use along with Invidious.

You can read more here: https://docs.invidious.io/applications/


## Contribute

### Code

1.  Fork it ( https://github.com/iv-org/invidious/fork ).
1.  Create your feature branch (`git checkout -b my-new-feature`).
1.  Stage your files (`git add .`).
1.  Commit your changes (`git commit -am 'Add some feature'`).
1.  Push to the branch (`git push origin my-new-feature`).
1.  Create a new pull request ( https://github.com/iv-org/invidious/compare ).

### Translations

We use [Weblate](https://weblate.org) to manage Invidious translations.

You can suggest new translations and/or correction here: https://hosted.weblate.org/engage/invidious/.

Creating an account is not required, but recommended, especially if you want to contribute regularly.
Weblate also allows you to log-in with major SSO providers like Github, Gitlab, BitBucket, Google, ...


## Projects using Invidious

A list of projects and extensions for or utilizing Invidious can be found in the documentation: https://docs.invidious.io/applications/

## Liability

We take no responsibility for the use of our tool, or external instances
provided by third parties. We strongly recommend you abide by the valid
official regulations in your country. Furthermore, we refuse liability
for any inappropriate use of Invidious, such as illegal downloading.
This tool is provided to you in the spirit of free, open software.

You may view the LICENSE in which this software is provided to you [here](./LICENSE).

>   16. Limitation of Liability.
>
> IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
