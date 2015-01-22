### **CoreOS**
-----

A development environment for playing about with CoreOS. Included under the services/ is a collection of components for building out a docker environment:

>  - **Service Discovery / Monitoring**: using either etcd and of consul
>  - **Service Registration**: via [service-registator](github.com/gambol99/service-registrar) and or [registrator](github.com/progrium/registrator)
>  - **Resource Management / Scheduling**: a clustered setup for Apache Mesos (multi-master / slaves) and clustered Marathon for docker deployments
>  - **Service Auto-wiring**: auto-wiring and load balancing of container services performed by the [Embassy](ithub.com/gambol99/embassy) project.
>  - **HTTP Router**: via HAproxy and or Vulcand, along side auto registration of backends, frontends and potentially url breakdowns i.e api.domain/orders to here, /session to this cluster, /admin/* over there ete etc 
>  - **Dynamic Configuration**: a proof concept project ([config-fs](github.com/gambol99/config-fs)) using templated and dynamic configuration. 
>  - **Marathon Demo**: a collection of Marathon deployments, comprising of a classic three-tier system, using to demo out the above setup.

#### **Services**

View the docs/ directory the details around the specific sections

#### **Vagrant Configuration**

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

#### **Setup**

    [jest@starfury coreos-vagrant]$ vagrant status
    Current machine states:

    core101                   not created (virtualbox)
    core102                   not created (virtualbox)
    core103                   not created (virtualbox)

    This environment represents multiple VMs. The VMs are all listed
    above with their current state. For more information about a specific
    VM, run `vagrant status NAME`.

    [jest@starfury coreos-vagrant]$ vagrant up


#### **Fleetctl**

Asumming you've built the fleetctl cli and place it into the PATH

    [jest@starfury services]$ export FLEETCTL_ENDPOINT=http://10.0.1.101:4001
    [jest@starfury services]$ fleetctl list-machines
    MACHINE   IP    METADATA
    2eca5343... 10.0.1.103  -
    789ec339... 10.0.1.102  -
    ba95766b... 10.0.1.101  -



#### **Issues**

I've noticed that on occasion the cloudinit doesnt work correctly; To manually process the cloudinit user-data you can perform the following; or better yet, workout the underlining reason :-)

    core@core103 ~ $ sudo su
    core103 core # /usr/bin/coreos-cloudinit --from-file /var/lib/coreos-vagrant/vagrantfile-user-data
    core@core103 # /usr/bin $ curl localhost:4001/v1/machines; echo
    http://10.0.1.101:4001, http://10.0.1.102:4001, http://10.0.1.103:4001
    core@core103 # /usr/bin $

    Note: some of the services under /services reference the interface; by default i leave these on Vagrant i.e. eth1 .. but for other platforms you'll need to change this to eth0 (like mesos, embassy, marathon etc)
    
#### **Contributing**

 - Fork it
 - Create your feature branch (git checkout -b my-new-feature)
 - Commit your changes (git commit -am 'Add some feature')
 - Push to the branch (git push origin my-new-feature)
 - Create new Pull Request
 - If applicable, update the README.md
