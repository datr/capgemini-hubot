
$config = loadyaml('/vagrant/config.yml')

class { "apt":
  always_apt_update => true,
  proxy_host => $config["proxyhost"],
  proxy_port => $config["proxyport"],
}


# Node.js
# -------
#
# The versions of node and npm in the Ubunut repos for raring and earlier [#f1]_
# are quite out of date so we use Chris Lea's ppa [#f2]_ in order to get the
# latest release and be able to use the most up to date version of hubot. We
# need this mainly to ensure compatability with the hubot-scripts repo as there
# is no version matching between the repos which leads to problems such as
# https://github.com/github/hubot/issues/517.
#
# .. [#f1] http://packages.ubuntu.com/raring/nodejs
# .. [#f2] https://launchpad.net/~chris-lea/+archive/node.js

class { 'nodejs' : 
  manage_repo => true,
  proxy => '',
}

# There is a naming conflict between nodejs and Amateur Packet Radio Node
# Program so the package was renamed [#f1]_. We want to use node though so crate
# a symlink.
#
# .. [#f1] https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#ubuntu-mint-elementary-os

if $::operatingsystemrelease >= 13.04 {
	file { '/usr/bin/node':
	   ensure => 'link',
	   target => '/usr/bin/nodejs',
	   require => Package['nodejs'],
	}
}

# Coffee Script
# -------------
#
# Required by hubot.

package { 'coffee-script':
  provider => 'npm',
}

# Hubot
# -----

package { 'hubot':
  provider => 'npm',
}

# Foreman
# -------

package { "rubygems" : }

package { 'foreman':
    provider => 'gem',
    require => Package['rubygems'],
}

# Skype4Py
# --------

package { "python-pip" : }

package { "Skype4Py" :
  provider => pip,
  require => Package["python-pip"],
}

# x11 transport doesn't seem to be working.
# Can't install dbus-python via pip.
# http://stackoverflow.com/a/13367555/1381644

package { "dbus-x11" : }
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

# Squid
# -----
#
# Proxychains doesn't distinguish between traffic destinted for a remote
# location and local services so we point it at a local proxy which is slightly
# smarter and have it do the heavy lifting.

package { "squid3" : }

service { 'squid3':
  ensure    => running,
  enable    => true,
  subscribe => File['/etc/squid3/squid.conf'],
  require => Package['squid3'],
}

# Make some configuration changes.
# 1. Add the proxy on the host machine as the default parent proxy.
# 2. Set never_direct to all to force all requests through the parent proxy.
# 3. Add a cache_peer_access exception for requests to services running inside
#    the container.
# 4. http_access will block CONNECT requests to non-ssl ports so just replace
#    that config with something that allows everyone to use squid. No ones
#    going to see this service anyway.
file { "/etc/squid3/squid.conf" :
  content => template("squid.erb"),
  require => Package['squid3'],
}

# Hubot
# -----

# Use foreman to manage environment variables:
# https://devcenter.heroku.com/articles/config-vars
# exec { "export DISPLAY=:1 && /opt/hubot/bin/hubot -a skype --name deanbot" : }
# exec { "foreman start" : }

# Jenkins Notification Plugin
# ---------------------------

# Set up the ssh hosts.
file { "/home/vagrant/.ssh/config" : 
  source => "/vagrant/files/home/vagrant/.ssh/config",
}

# Use autossh to maintain the jenkins tunnel.
package { 'autossh' : }


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
