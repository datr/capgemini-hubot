
class { 'apt': }


# Node.js
# -------

package { "nodejs" : }
package { "npm" : }

# There is a naming conflict between nodejs and Amateur Packet Radio Node
# Program so the package was renamed [#f1]_. We want to use node though so crate
# a symlink.
#
# .. [#f1] https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#ubuntu-mint-elementary-os

# file { '/usr/bin/node':
#    ensure => 'link',
#    target => '/usr/bin/nodejs',
#    require => Package['nodejs'],
# }

# Skype4Py
# --------

package { "python-pip" : }

package { "Skype4Py" :
  provider => pip,
  require => Package["python-pip"],
}

# x11 transport doesn't seem to be working.
# Can't instlal dbus-python via pip.
# http://stackoverflow.com/a/13367555/1381644

package { "python-dbus" : }
package { "python-gobject" : }

# Reddis
# ------
#
# Used for hubot brain.

package { "redis-server" : }

# Proxychains
# -----------
#
# Hubot doesn't have support for proxies so use proxychains to reroute all of
# its traffic. [#f2]_
#
# .. [#f2] https://github.com/github/hubot/issues/287

package { "proxychains" : }

# Hubot
# -----

# Use foreman to manage environment variables:
# https://devcenter.heroku.com/articles/config-vars
# export HUBOT_LOG_LEVEL=DEBUG
# export HUBOT_JIRA_URL=https://jira.capgeminidigital.com
# export HUBOT_JIRA_USER=deanr
# export HUBOT_JIRA_PASSWORD=
# export HUBOT_JIRA_USE_V2=true
# export HUBOT_TWITTER_CONSUMER_KEY=A59QNl9hSARZiAg5HZXzQ
# export HUBOT_TWITTER_CONSUMER_SECRET=X9c6xmtDtQQ7Pyko7QErbIUNOIJ4WOKhOvDbPPxgNQ
# export HUBOT_TWITTER_ACCESS_TOKEN_KEY=14971150-YlaJUawakGbLreR9dOeVhWKjFMqdKmGCUPIJh8TO8
# export HUBOT_TWITTER_ACCESS_TOKEN_SECRET=rSLzf900xLddbpZUjMQcqNhI2q3IAOwghFZuCAYDE
# exec { "export DISPLAY=:1 && /opt/hubot/bin/hubot -a skype --name deanbot" : }

# Install a GUI
# -------------
#
# The idea to run skype in a virtual frame buffer and vnc in was borrowed from
# the sevabot project [#f2]_.
#
# .. [#f2] https://sevabot-skype-bot.readthedocs.org/en/latest/ubuntu.html

# xvfb
# ^^^^
#
# X virtual framebuffer is a display server implementation of the X11 display
# server protocol that runs entirely in memory and doens't require physical
# output or input devices [#f3]_.
#
# .. [#f3] http://en.wikipedia.org/wiki/Xvfb

package { "xvfb" : }
# exec { "Xvfb :1 -screen 0 800x600x16 &" : }

# Fluxbox
# ^^^^^^^
#
# Fluxbox is an incredibly light weight window manager. [#f4]_
#
# .. [#f4] http://www.wikivs.com/wiki/Fluxbox_vs_LXDE#Fluxbox

package { "fluxbox" : }
# exec { "fluxbox -display :1 &" : }

# VNC
# ^^^
#
# Use x11vnc to allow access to the GUI.

package { "x11vnc" : }
# exec { "x11vnc -display :1 -bg -xkb" : }

# Installe Skype
# --------------

apt::source { 'partner':
  location   => 'http://archive.canonical.com/',
  repos      => 'partner',
}

package { "skype" : 
  require => Apt::Source['partner'],
}

# exec { "skype > /dev/null 2&>1 &" : }
