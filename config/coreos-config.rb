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
  :userdata_file       => 'config/cloudinit.yaml.erb',
  :instance_index      => 101,
  :discovery_token     => nil,
  :discovery_url       => "https://discovery.etcd.io/new",
  :domain              => "",
  :virtualbox => {
    :name => "coreos",
    :url  => "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json",
    :resources => {
      :cpus         => 2,
      :memory       => 2048,
      :biosbootmenu => 'disabled'
    }
  },
  :aws => {
    :flavor    => 't2.micro',
    :image     => 'ami-7e5d3d16',
    :keypair   => 'default',
    :region    => 'eu-west-1',
    :subnet_id => 'subnet-eafb31b3'
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

def userdata_file
  @userdata_file ||= File.read(coreos[:userdata_file])
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
