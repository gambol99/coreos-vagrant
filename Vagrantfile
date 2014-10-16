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

VAGRANTFILE_API_VERSION = "2"
USERDATA = 'config/cloudinit.yaml.erb'


def discovery_token
  @discovery_token ||= get_discovery_token
end

def vagrant_command
  ARGV[0]
end

def get_discovery_token
  if coreos[:discovery_token] =~ /^new/
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
      x.vm.box       = "coreos-#{coreos[:coreos_channel]}"
      x.vm.box_url   = "#{coreos[:instance][:url]}" % [ coreos[:coreos_channel] ]
      x.vm.host_name = hostname
      x.vm.network :private_network, ip: "#{coreos[:network]}" % [ index ]
      x.vm.provider :virtualbox do |v|
        v.gui   = true
        v.name  = hostname
        coreos[:instance][:resources].each_pair do |key,value|
          v.customize [ "modifyvm", :id, "--#{key}", value ]
        end
      end
      if File.exist?(USERDATA) and File.readable?(USERDATA)
        x.vm.provision :shell, :inline => cloudinit, :privileged => true
      end
    end
  end
end
