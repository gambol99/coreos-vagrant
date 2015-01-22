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

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box_check_update = true
  discovery_token if vagrant_command =~ /(up|provision)/
  coreos[:coreos_cluster_size].times.each.with_index(coreos[:instance_index]) do |x,host_index|
    # step: get the configuation and domain
    @hostname = "core#{host_index}"

    # step: i have no idea how to get the provider being used - unless we do some hack and
    # check the command line????
    aws_cloud_init  = ERB.new( File.read(aws_cfg[:userdata]), nil, '-' ).result( binding )
    vbox_cloud_init = ERB.new( File.read(virtualbox_cfg[:userdata]), nil, '-' ).result( binding )

    config.vm.define @hostname do |x|
      x.vm.host_name = "core#{host_index}"
      x.vm.box       = 'coreos-%s' % [ coreos[:coreos_channel] ]
      x.vm.box_url   = "#{virtualbox_cfg[:url]}" % [ coreos[:coreos_channel] ]

      #
      # Virtualbox related configuration
      #
      x.vm.provider :virtualbox do |virtualbox,override|
        virtualbox.gui   = false
        virtualbox.name  = "core#{host_index}"
        virtualbox_cfg[:resources].each_pair do |key,value|
          virtualbox.customize [ "modifyvm", :id, "--#{key}", value ]
        end

        # step: the override for virtualbox
        override.vm.network :private_network, ip: "#{coreos[:network]}" % [ host_index ]
        override.vm.provision :shell, :inline => vbox_cloud_init, :privileged => true
      end

      #
      # Amazon EC2 related configuration
      #
      x.vm.provider :aws do |aws, override|
        # the credentials are pull from environment variables only
        aws.access_key_id     = ENV['AWS_ACCESS_KEY']
        aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
        aws.region            = aws_cfg[:region] || 'eu-west-1'
        aws.instance_type     = aws_cfg[:flavor] || 'm1.small'
        aws.subnet_id         = aws_cfg[:subnet_id]
        aws.availability_zone = aws_cfg[:availability_zone] if aws_cfg[:availability_zone]
        aws.elastic_ip        = aws_cfg[:elastic_ip]
        aws.user_data         = aws_cloud_init

        aws.tags              = {
          'Name' => "core#{host_index}",
          'Type' => 'CoreOS'
        }

        aws.region_config 'us-east-1' do |region|
          region.ami          = 'ami-3e750856'
          region.keypair_name = 'default'
        end

        aws.region_config 'eu-west-1' do |region|
          region.ami          = 'ami-e76dec90'
          region.keypair_name = 'default'
        end

        override.vm.box         = 'dummy'
        override.nfs.functional = false
        override.ssh.username   = 'core'
        override.ssh.private_key_path = "#{ENV['HOME']}/.ssh/id_rsa"
      end
    end
  end
end
