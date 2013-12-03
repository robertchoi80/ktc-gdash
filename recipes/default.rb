# CookBook:: ktc-gdash
# Recipe:: default
#

include_recipe "partial_search"
include_recipe "services"

ruby_block "load graphite endpoint" do
  block do
    endpoint = Services::Endpoint.new "graphite"
    endpoint.load

    node.set[:gdash][:graphite_url] = "http://#{endpoint.ip}:#{node[:graphite][:listen_port]}"

    system('touch /var/lock/.graphite_endpoint_loaded')
  end
  action :create
  not_if "test -f /var/lock/.graphite_endpoint_loaded"
end

include_recipe "gdash::default"

search_query = "recipes:#{node[:gdash][:monitor_client_recipe]}"
nodes = partial_search(:node, search_query, :keys => { 'fqdn' => ['fqdn'] })
category_name = ''

nodes.each do |node|
  node_fqdn = node['fqdn']
  next if node_fqdn.nil?

  # Make it consistent to Graphite whisper format
  node_name = node_fqdn.gsub(/\./, '_')
  Chef::Log.info "Creating entry #{node_fqdn}..."

  if node_fqdn.start_with?("cnode")
    category_name = 'cnode'
  elsif node_fqdn.start_with?("snode")
    category_name = 'snode'
  elsif node_fqdn.start_with?("mnode")
    category_name = 'mnode'
  else
    category_name = 'management-vm'
  end

  # Unfortunately, this lwrp doesn't have 'properties' parameter. Can't specify time zone here. I'll submit PR soon.
  gdash_dashboard node_fqdn do
    category category_name
    description node_fqdn
  end

  # These metrics might be changed to hash attributes later.
  gdash_dashboard_component 'load' do
    dashboard_name node_fqdn
    dashboard_category category_name
    title "Load"
    fields(
      :shortterm => {
        :data => "#{node_name}.load.load.shortterm",
        :alias => 'shortterm'
      },
      :midterm => {
        :data => "#{node_name}.load.load.midterm",
        :alias => 'midterm'
      },
      :longterm => {
        :data => "#{node_name}.load.load.longterm",
        :alias => 'longterm'
      }
    )
  end

  gdash_dashboard_component 'cpu' do
    dashboard_name node_fqdn
    dashboard_category category_name
    title "CPU"
    fields(
      :iowait => {
        :data => "averageSeries(#{node_name}.cpu.*.cpu.wait.value)",
        :alias => 'IO Wait'
      },
      :system => {
        :data => "averageSeries(#{node_name}.cpu.*.cpu.system.value)",
        :alias => 'system'
      },
      :user => {
        :data => "averageSeries(#{node_name}.cpu.*.cpu.user.value)",
        :alias => 'user'
      }
    )
  end

  gdash_dashboard_component 'memory' do
    dashboard_name node_fqdn
    dashboard_category category_name
    title "Memory"
    fields(
      :iowait => {
        :data => "#{node_name}.memory.memory.used.value",
        :alias => 'memory used'
      }
    )
  end
end
