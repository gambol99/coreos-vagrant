#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-10-16 10:24:21 +0100 (Thu, 16 Oct 2014)
#
#  vim:ts=2:sw=2:et
#
$:.unshift File.join(File.dirname(__FILE__),'.')
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'net/http'
require 'erb'
require 'config/coreos-config'

VAGRANTFILE_API_VERSION  = "2"
VAGRANT_DEFAULT_PROVIDER = :virtualbox
USERDATA                 = 'config/cloudinit.yaml.erb'

def discovery_token
  @discovery_token ||= get_discovery_token
end

def vagrant_command
  ARGV[0]
end

def get_discovery_token
  if coreos[:discovery_token].nil?
    begin
      coreos[:discovery_token] = Net::HTTP.get(URI.parse(coreos[:discovery_url]))
    rescue Exception => e
      raise "unable to get a token from the discovery service:" #
    end
  end
  coreos[:discovery_token]
end

def cloudinit
  @cloudinit ||= ERB.new( File.read(USERDATA), nil, '-' ).result( binding )
end

def coreos
  @coreos ||= {}
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box_check_update = true
  # step: do we need a discovery code?
  discovery_token if vagrant_command =~ /(up|provision)/
  coreos[:coreos_instances].times.each.with_index(coreos[:instance_index]) do |x,index|
    hostname = "core#{index}"
    config.vm.define hostname do |x|
      x.vm.host_name = hostname
      x.vm.box       = "coreos-#{coreos[:coreos_channel]}"
      x.vm.box_url   = "#{coreos[:instance][:url]}" % [ coreos[:coreos_channel] ]

      # VirtualBox provider
      x.vm.provider :virtualbox do |v,override|
        v.gui   = false
        v.name  = hostname
        coreos[:instance][:resources].each_pair do |key,value|
          v.customize [ "modifyvm", :id, "--#{key}", value ]
        end
        override.vm.network :private_network, ip: "#{coreos[:network]}" % [ index ]
        override.vm.provision :shell, :inline => cloudinit, :privileged => true
      end

      # AWS Provider
      config.vm.provider :aws do |aws, override|
        aws.access_key_id     = ENV['AWS_ACCESS_KEY']
        aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
        aws.region            = ENV['AWS_REGION'] || 'eu-west-1'
        aws.subnet_id         = ENV['AWS_VPC_SUBNET_ID'] if ENV['AWS_VPC_SUBNET_ID']

        aws.instance_type     = 'm3.medium'
        aws.region_config "us-east-1" do |region|
          region.ami          = 'ami-7e5d3d16'
          region.keypair_name = 'default'
        end
        aws.region_config "eu-west-1" do |region|
          region.ami          = 'ami-7a3a840d'
          region.keypair_name = 'hackday'
        end
        aws.tags = {
          'Name' => hostname
        }
        aws.user_data         = cloudinit

        override.vm.box       = 'dummy'
        override.ssh.username = 'root'
      end
    end
  end
end
