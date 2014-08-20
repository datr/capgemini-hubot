db
==

A hubot based chat bot for Capgemini Digital.

Requirements
------------

* Git
* Vagrant
* Vagrant lxc
* nfsd

Setup
-----

1. Clone the git repo.

2. Grab the submodules::

    git submodule init && git submodule update

3. Set the proxy to use (if any) in vagrant/config.yml.

4. Start vagrant.

    cd vagrant && vagrant up --provider lxc

5. Install the node dependencies::

    cd /opt/hubot
    npm install

6. Copy hubot/example.env to hubot/.env and edit it to match your environment
   details.

7. Start foreman::

     cd /opt/hubot
     foreman start


Installing Skype4Py
^^^^^^^^^^^^^^^^^^^

The pip --proxy option seems to be broken so for now you'll need to install
this package manually if you're behind a proxy.

Configuring Skype
^^^^^^^^^^^^^^^^^

If you're behind a proxy and want to configure Skype to use it before the first
login, press Ctrl+O at the login screen to open the options dialog.

Jenkins Notifications
^^^^^^^^^^^^^^^^^^^^^

Jenkins notifications are created by using the jenkins-notifier.coffee script
[#f1]_. In order for Jenkins to be able to hit the web server we need to
establish a reverse ssh tunnel to the jenkins server.

1. Make sure you can access the jenkins server from your host machine via ssh
   key. We use agent forwarding to share your keys with the deanbot container.

2. Connect to the jump server in the container::

     ssh rmg.jenkins

   And add the host keys for the jump server and jenkins server to your trusted
   list.

3. Finally use autossh to establish a permanent tunnel::

     autossh -f -N -R 5000:localhost:5000 rmg.jenkins

N.B. The jenkins jobs will also need to be configured to call out to deanbot.
See the script doc block for details on how to configure this.

Footnotes
---------
.. [#f1] https://github.com/github/hubot-scripts/blob/master/src/scripts/jenkins-notifier.coffee
