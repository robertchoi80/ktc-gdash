# vim: set ft=ruby:
site :opscode

metadata
group "other" do
  cookbook "graphite", github: "hw-cookbooks/graphite"
  cookbook "collectd", github: "miah/chef-collectd"
  cookbook "gdash", github: "hw-cookbooks/gdash"
  cookbook "sensu", github: "sensu/sensu-chef"
  cookbook "redis", github: "miah/chef-redis"
  cookbook "services", github: "spheromak/services-cookbook"
  cookbook "ktc-etcd", github: "cloudware-cookbooks/ktc-etcd", branch: "develop"
  cookbook "ktc-utils", github: "cloudware-cookbooks/ktc-utils", branch: "develop"
  cookbook 'openstack-common', github: 'stackforge/cookbook-openstack-common'
end

group "ktc" do
  cookbook 'ktc-monitor', github: 'cloudware-cookbooks/ktc-monitor'
  cookbook 'ktc-collectd', github: 'cloudware-cookbooks/ktc-collectd'
  cookbook 'ktc-sensu', git: 'git@github.com:cloudware-cookbooks/ktc-sensu.git', branch: 'develop'
end

group "integration" do
  cookbook 'chef-solo-search', github: 'edelight/chef-solo-search'
end
