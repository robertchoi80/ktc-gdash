# vim: set ft=ruby:
site :opscode

metadata
group "other" do
  cookbook "graphite", github: "hw-cookbooks/graphite"
  cookbook "collectd", github: "miah/chef-collectd"
  cookbook "gdash", github: "hw-cookbooks/gdash"
  cookbook "ubuntu"
end

group "ktc" do
  cookbook 'ktc-collectd', github: 'cloudware-cookbooks/ktc-collectd'
end

group "integration" do
  cookbook 'chef-solo-search', github: 'edelight/chef-solo-search'
end
