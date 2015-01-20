#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-10-16 10:24:14 +0100 (Thu, 16 Oct 2014)
#
#  vim:ts=2:sw=2:et
#
@coreos = {
  :coreos_channel   => "alpha",
  :coreos_version   => ">= 308.0.1",
  :coreos_instances => 3,
  :coreos_userdata  => "./config/cloudinit.yaml.erb",
  :network          => "10.0.1.%d",
  :domain           => "",
  :instance_index   => 101,
  :discovery_token  => nil,
  :discovery_url    => "https://discovery.etcd.io/new",
  :instance => {
    :name => "coreos",
    :url  => "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json",
    :resources => {
      :cpus         => 2,
      :memory       => 2048,
      :biosbootmenu => "disabled",
    }
  },
  # configuration related to ec2 instances
  :ec2 => {
    :flavor    => "t2.micro",
    :image     => "ami-7e5d3d16",
    :keypair   => "default",
    :region    => "eu-west-1",
    :subnet_id => "subnet-eafb31b3"
  }
}

def ec2
  @coreos[:ec2] || {}
end
