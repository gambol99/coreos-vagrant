### **CoreOS**
-----

A development environment for playing about with CoreOS. Included under the services/ is a collection of components for building out a docker environment:

 * *Note: i'm trying to strip out the services element from the vagrant environment, thus i'm moving most of the service over to [docker-logistics](https://github.com/gambol99/docker-logistics)  repository.*   

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
	  :coreos_channel      => "alpha",
	  :coreos_version      => ">= 308.0.1",
	  :coreos_cluster_size => 3,
	  :network             => "10.0.1.%d",
	  :instance_index      => 101,
	  :discovery_token     => nil,
	  :discovery_url       => "https://discovery.etcd.io/new",
	  :domain              => "domain.com",
	  ...

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

#### **Provider Notes & Issues**

##### **Etcd Dicovery Token**

By default the discovery token for etcd is left blank, by doing so on the first 'vagrant up' it's calls the endpoint and retrieves a fresh token. This is handy, but comes with one caveat ; namely that if the cluster is not built all in one go (within the same vagrant up), the token will change, thus any new boxes - well you get the idea. Fixing this would be 

* getting your own token from the endpoint and filling in the below
* changing the discovery_token method - perhaps on nil down and write to file and reload on next 'up'
* grabbing the token from a already built box

		:discovery_token     => nil,
		:discovery_url       => "https://discovery.etcd.io/new",

*Note: I might implement the middle one, haven't decided yet.*

##### **Cluster Joining**

I've noticed that on occasion the cloudinit doesnt work correctly; To manually process the cloudinit user-data you can perform the following; or better yet, workout the underlining reason why :-) 

    core@core103 ~ $ ls bin/
    # you should see a bunch of fixup scripts depending on the provider
    [jest@starfury coreos-vagrant]$ ls bin/ -l
	total 16
	-rwxrwxr-x 1 jest jest 156 Jan 22 11:31 coreos-aws-fixup
	-rwxrwxr-x 1 jest jest 982 Jan 22 13:15 coreos-fixup
	-rw-rw-r-- 1 jest jest 162 Jan 22 11:36 coreos-openstack-fixup
	-rwxrwxr-x 1 jest jest 163 Jan 22 11:31 coreos-virtualbox-fixup

Effectively all these are doing as logging in a re-running the cloudinit process. 

##### **Network Interfaces**

Some of the services under /services reference the interface; by default i leave these on Vagrant i.e. eth1 .. but for other platforms you'll need to change this to eth0 (like mesos, embassy, marathon etc)

##### Amazon EC2 Provider

The configuration information for EC2 can be found in *config/coreos-config.rb* 

	:aws => {
	    :flavor     => 'm1.small',
	    :image      => 'ami-7e5d3d16',
	    :userdata   => 'config/cloudinit.aws.erb',
	    :keypair    => 'default',
	    :region     => 'eu-west-1',
	    :subnet_id  => 'subnet-XXXXXXXX',  # your VPC subnet id
	    :elastic_ip => true  # your choice, depends on the setup your running in
	}

	# You'll need to export the AWS Security credentials for api access
	
	aws.access_key_id     = ENV['AWS_ACCESS_KEY']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    
#### **Contributing**

 - Fork it
 - Create your feature branch (git checkout -b my-new-feature)
 - Commit your changes (git commit -am 'Add some feature')
 - Push to the branch (git push origin my-new-feature)
 - Create new Pull Request
 - If applicable, update the README.md
