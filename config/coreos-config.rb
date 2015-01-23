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
  :network             => "10.0.1.%d",
  :instance_index      => 101,
  :discovery_token     => nil,
  :discovery_url       => "https://discovery.etcd.io/new",
  :domain              => "domain.com",
  # Obvisouly change these for you own keys - this ONLY effects the openstack / aws providers
  # as virtualbox keys are left untouched
  :ssh_authorized_keys => [
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7K4+mLac9yexhMY5N+XtQIbTFHxVJJLlpm4/DJw3HET25AZpy7AeBDhQwgjYHd+saPUuocxNkztmYelgXkIWhIwWn2vODt0wBryt1skNs07mVm+jPawNRrEs9q+uVVAn64P+2WmyJVgsFWOkKkrnH/sypJnLSNk8WDdpqD6JLz4fsy9+zinMh7k7Xo5UfBq78pVfUS9aVlMpOj3NmdD1UpxbIBsC+ttlVR43rqrnySK9zhzezYot4PlA1LInnw8E7o8TxnJ6z2xXx5PsNMbjLW94OjpjsbvbKsKnLunA2LMc65HtOAVdPqHTWxbMuSlKjChiWJDjujdjVID8FpW09 imported-openssh-key',
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD2TMUDqvIjPtfRsbUkqADC9Y47pWYAPGfaH5FkGijm5AtYIZI465/IHR517Ofbd+eeLrBp5VyAVUYcUyZOfLvINIYBcAMZDuzMZV3hQYiCj6whnPzq5ItAgd7KJUKYKWgAUvA0dfacM5STe7woH4Bg9L7kExs9q/1GonYynUBkOdmX6rP8SdG2kfcauvIS7YQkdUW+oymb8kge4zVd/WuqjId95wGHhkFzq/4CeqFFCd/dOjW/61yTp/E6Ms8Gd3NwNLD7l60AulMqRkxHJnMH3rAGSyhyvhLFqwpcc5/5wpaibsAW0oKwCEn/FC12WythVy+g4HAIwHKHCDRVPzqH jest@starfury'
  ],
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
      # step: lets check if a discovery token exists on file
      coreos[:discovery_token] = Net::HTTP.get(URI.parse(coreos[:discovery_url]))
    rescue Exception => e
      raise "unable to get a token from the discovery service:" #
    end
  end
  coreos[:discovery_token]
end
