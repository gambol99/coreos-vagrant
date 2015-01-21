#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-10-16 10:24:14 +0100 (Thu, 16 Oct 2014)
#
#  vim:ts=2:sw=2:et
#
@coreos = {
  :coreos_channel      => "alpha",
  :coreos_version      => ">= 308.0.1",
  :coreos_cluster_size => 3,
  :coreos_userdata     => "./config/cloudinit.yaml.erb",
  :network             => "10.0.1.%d",
  :instance_index      => 101,
  :discovery_token     => nil,
  :discovery_url       => "https://discovery.etcd.io/new",
  :domain              => "",
  :virtualbox => {
    :name => "coreos",
    :url  => "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json",
    :userdata  => 'config/cloudinit.virtualbox.erb',
    :resources => {
      :cpus         => 2,
      :memory       => 2048,
      :biosbootmenu => 'disabled'
    }
  },
  :aws => {
    :flavor     => 'm1.small',
    :image      => 'ami-7e5d3d16',
    :userdata   => 'config/cloudinit.aws.erb',
    :keypair    => 'default',
    :region     => 'eu-west-1',
    :subnet_id  => 'subnet-eafb31b3',
    :elastic_ip => true
  }
}

def coreos
  @coreos
end

def aws_cfg
  @coreos[:aws] || {}
end

def virtualbox_cfg
  @coreos[:virtualbox] || {}
end

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
