CoreOS Vagrant
==============

A vagrant development environment for playing about with CoreOS

Config
--------

The configraution file is located in config/coreos-config.rb

    @coreos = {
      :coreos_channel   => "alpha",
      :coreos_version   => ">= 308.0.1",
      :coreos_instances => 3, # UPDATE: for the number of coreos instances you want
      :coreos_userdata  => "./config/cloudinit.yaml.erb",
      :network          => "10.0.1.%d",
      :instance_index   => 101,
      :discovery_token  => nil,
      :discovery_url    => "https://discovery.etcd.io/new",
      :instance => {
        :name => "coreos",
        :url  => "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json",
        :resources => {
          :gui          => false,
          :cpus         => 2,
          :memory       => 1024,
          :biosbootmenu => "disabled",
        }
      }
    }

Its self explanatory, so wont bother with a description; Note, if you want to use a predefined discovery service token, just place the url in :discovery_token above, otherwise it will pull a new token from default discovery url (:discovery_url)

Setup
--------

    [jest@starfury coreos-vagrant]$ vagrant status
    Current machine states:

    core101                   not created (virtualbox)
    core102                   not created (virtualbox)
    core103                   not created (virtualbox)

    This environment represents multiple VMs. The VMs are all listed
    above with their current state. For more information about a specific
    VM, run `vagrant status NAME`.

    [jest@starfury coreos-vagrant]$ vagrant up


Fleetclt
--------

Asumming you've built the fleetctl cli and place it into the PATH

    [jest@starfury services]$ export FLEETCTL_ENDPOINT=http://10.0.1.101:4001
    [jest@starfury services]$ fleetctl list-machines
    MACHINE   IP    METADATA
    2eca5343... 10.0.1.103  -
    789ec339... 10.0.1.102  -
    ba95766b... 10.0.1.101  -

Issues
--------

I've noticed that on occasion the cloudinit doesnt work correctly; To manually process the cloudinit user-data you can perform the following; or better yet, workout the underlining reason :-)

    core@core103 ~ $ sudo su
    core103 core # /usr/bin/coreos-cloudinit --from-file /var/lib/coreos-vagrant/vagrantfile-user-data
    core@core103 # /usr/bin $ curl localhost:4001/v1/machines; echo
    http://10.0.1.101:4001, http://10.0.1.102:4001, http://10.0.1.103:4001
    core@core103 # /usr/bin $
