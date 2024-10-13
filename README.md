# REPOSITORY MOVED
Please note the repository has been moved from mooleshacat/invidious to catspeed-cc/invidious.

You can update your local clone with ```git remote set-url origin https://github.com/catspeed-cc/invidious```

At the moment, master banch is still a clone of iv-org/master. All changes currently are inside development branch. I will merge development into master in time.

As of [PR #1](https://github.com/catspeed-cc/invidious/pull/1) the dev-http-proxy branch has been merged into development branch.

```git checkout development``` will switch you to the working branch (the one running on catspeed.cc).

<br />

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
- revert of d9df90b fixes signin error
- add http proxy
- add redis server (see "Hosting invidious" below)

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
- create a support ticket here https://github.com/catspeed-cc/invidious/issues
- please do not create tickets elsewhere.


## Quick start

**Using invidious:**

- [Select a public instance from the list](https://instances.invidious.io) and start watching videos right now!

**Hosting invidious:**

Note: You still require postgresql as only some things are using redis. You should notice an increase in speed when loading pages/feeds/videos. You should also notice a decrease in disk usage.

- Install redis-server & enable ```apt install -y redis-server ; systemctl enable redis-server ;```
  - Compile and start Invidious
  - Check logs for ```Oct 13 20:20:11 catspeed invidious[1110061]: Connected to redis```
  - check connections ```netstat -tlnpa | grep :6379``` for established connections to :6379
- [Follow the installation instructions](https://docs.invidious.io/installation/)

**Notice to instance owners:**

It appears the working solution currently is to use:
- sig helper
- po_token & visitor_data
- a VPN proxy (privoxy, proton-privoxy, etc.)

I personally use proton VPN, you can get it along with your email here: https://pr.tn/ref/04PN5S3WMGBG - if you want VPN only you can try to get it there or just go to https://protonvpn.com . You can get a working proton-privoxy from https://github.com/catspeed-cc/proton-privoxy .

I use one invidious instance, one sig helper, and one proton-privoxy per core. Each connection to nginx is routed to the least connected backend (currently I have 4) . If you only have 1 core, use 2 processes so you can restart one at a time, minimizing downtime. I hope this is helpful to instance owners having troubles.

Public and private instance owners: if you need help with anything, create an issue ticket here: https://github.com/catspeed-cc/invidious/issues - I do not mind, I will try and help best I can.


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


## po_token and visitor_data notes

This branch has the token monitor patch from myself (mooleshacat) which if not disabled in config file will check every 1 minute your config file for updated tokens. Now all you have to do is make a bash script that updates the tokens in the config file and a cronjob to execute it at the desired interval. No longer do you have to restart invidious service for the tokens to update.

This patch is a temporary workaround until inv_sig_helper itself can get the tokens for us. unixfox (invidious dev) raised this idea to techmetx11 (inv_sig_helper dev) and they are working on an implementation that will eventually make this patch useless. This is OK, as it is only a patch and that setup would be better performance wise than my current implementations. You can read about it here https://github.com/iv-org/inv_sig_helper/issues/10


## uptime & loadavg status patch notes

This branch has the uptime & loadavg patch from myself (mooleshacat) which if enabled in the config, will show the uptime and/or loadavg on the page. Please note, if everyone can see your uptime or loadavg, so could a theoretical attacker. This may or may not be a good idea, you be the judge.


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
