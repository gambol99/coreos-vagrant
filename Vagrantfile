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
    @domain   = coreos[:domain]
    @hostname = "core#{host_index}"

    # step: we generate the cloudinit now
    user_data = ERB.new( userdata_file, nil, '-' ).result( binding )

    config.vm.define @hostname do |x|
      x.vm.host_name = @hostname
      x.vm.box       = 'coreos-%s' % [ coreos[:coreos_channel] ]
      x.vm.box_url   = "#{virtualbox_cfg[:url]}" % [ coreos[:coreos_channel] ]

      #
      # Virtualbox related configuration
      #
      x.vm.provider :virtualbox do |virtualbox,override|
        virtualbox.gui   = false
        virtualbox.name  = @hostname
        virtualbox_cfg[:resources].each_pair do |key,value|
          virtualbox.customize [ "modifyvm", :id, "--#{key}", value ]
        end

        # step: the override for virtualbox
        override.vm.network :private_network, ip: "#{coreos[:network]}" % [ host_index ]
        override.vm.provision :shell, :inline => user_data, :privileged => true
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
        aws.user_data         = user_data
        aws.tags              = {
          'Name' => @hostname,
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



        override.vm.box       = 'dummy'
        override.ssh.username = 'core'
      end
    end
  end
end
