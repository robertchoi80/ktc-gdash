# cat default.rb
# CookBook:: ktc-gdash
# Recipe:: default
#

include_recipe "partial_search"
include_recipe "services"

# Load graphite endpoint
endpoint = Services::Endpoint.new "graphite"
endpoint.load

# Override graphite url so that it can be written to gdash.yaml
node.set[:gdash][:graphite_url] = "http://#{endpoint.ip}:#{node[:graphite][:listen_port]}"

include_recipe "gdash::default"

# Search all nodes that runs ktc-monitor::client
search_query = "recipes:#{node[:gdash][:monitor_client_recipe]}"
client_nodes = search(:node, search_query)

category_name = ''
summary_category_name = ''
root_vol_size = 0

#############################
# Create summary dashboards #
#############################
%w(cnode mnode management-vm).each do |sum_category|
  %w(cpu load memory filesystem).each do |metric|
    gdash_dashboard metric do
      category "summary-#{sum_category}"
      description metric
    end
  end
end

client_nodes.each do |client|
  client_fqdn = client['fqdn']
  client_memory_total = client['memory']['total'].to_i
  next if client_fqdn.nil?

  # Get root volume size from node attribute
  client['filesystem'].each do |fs, value|
    if fs.include? "root" and not fs.eql?("rootfs")
      root_vol_size = value['kb_size'].to_i
      Chef::Log.debug("Root volume found. Size: #{root_vol_size}")
    end
  end

  # Make it consistent to Graphite whisper format
  client_name = client_fqdn.gsub(/\./, '_')
  Chef::Log.info "Creating entry #{client_fqdn}..."

  if client_fqdn.start_with?("cnode")
    category_name = 'cnode'
    summary_category_name = 'summary-cnode'
  elsif client_fqdn.start_with?("snode")
    category_name = 'snode'
    summary_category_name = 'summary-snode'
  elsif client_fqdn.start_with?("mnode")
    category_name = 'mnode'
    summary_category_name = 'summary-mnode'
  else
    category_name = 'management-vm'
    summary_category_name = 'summary-management-vm'
  end

  ###########################################
  # Create a dashboard for each client node #
  ###########################################
  gdash_dashboard client_fqdn do
    category category_name
    description client_fqdn
  end

  ###############################
  # Add graphs to the dashboard #
  ###############################

  gdash_dashboard_component 'cpu' do
    dashboard_name client_fqdn
    dashboard_category category_name
    title "CPU"
    fields(
      :iowait => {
        :data => "stacked(averageSeries(#{client_name}.cpu-*.cpu-wait.value))",
        :alias => 'IO Wait'
      },
      :system => {
        :data => "stacked(averageSeries(#{client_name}.cpu-*.cpu-system.value))",
        :alias => 'system'
      },
      :user => {
        :data => "stacked(averageSeries(#{client_name}.cpu-*.cpu-user.value))",
        :alias => 'user'
      }
    )
  end

  gdash_dashboard_component 'load' do
    dashboard_name client_fqdn
    dashboard_category category_name
    title "Load"
    fields(
      :shortterm => {
        :data => "#{client_name}.load.load.shortterm",
        :alias => 'shortterm'
      },
      :midterm => {
        :data => "#{client_name}.load.load.midterm",
        :alias => 'midterm'
      },
      :longterm => {
        :data => "#{client_name}.load.load.longterm",
        :alias => 'longterm'
      }
    )
  end

  gdash_dashboard_component 'memory' do
    dashboard_name client_fqdn
    dashboard_category category_name
    title "Memory"
    fields(
      :used => {
        :data => "#{client_name}.memory.memory-used.value",
        :alias => 'used'
      }
    )
  end

  gdash_dashboard_component 'filesystem' do
    dashboard_name client_fqdn
    dashboard_category category_name
    title "Filesystem"
    fields(
      :root_used => {
        :data => "#{client_name}.df-root.df_complex-used.value",
        :alias => 'root_used'
      }
    )
  end

  ########################################
  # Add graphs to the summary dashboards #
  ########################################

  gdash_dashboard_component client_fqdn do
    dashboard_name 'cpu'
    dashboard_category summary_category_name
    title client_fqdn
    fields(
      :iowait => {
        :data => "stacked(averageSeries(#{client_name}.cpu-*.cpu-wait.value))",
        :alias => 'IO Wait'
      },
      :system => {
        :data => "stacked(averageSeries(#{client_name}.cpu-*.cpu-system.value))",
        :alias => 'system'
      },
      :user => {
        :data => "stacked(averageSeries(#{client_name}.cpu-*.cpu-user.value))",
        :alias => 'user'
      }
    )
  end

  gdash_dashboard_component client_fqdn do
    dashboard_name 'load'
    dashboard_category summary_category_name
    title client_fqdn
    fields(
      :shortterm => {
        :data => "#{client_name}.load.load.shortterm",
        :alias => 'shortterm'
      },
      :midterm => {
        :data => "#{client_name}.load.load.midterm",
        :alias => 'midterm'
      },
      :longterm => {
        :data => "#{client_name}.load.load.longterm",
        :alias => 'longterm'
      }
    )
  end

  gdash_dashboard_component client_fqdn do
    dashboard_name 'memory'
    dashboard_category summary_category_name
    title client_fqdn
    ymin 0
    ymax 100
    fields(
      :used => {
        :data => "asPercent(#{client_name}.memory.memory-used.value, #{client_memory_total * 1000})",
        :alias => 'used'
      }
    )
  end

  gdash_dashboard_component client_fqdn do
    dashboard_name 'filesystem'
    dashboard_category summary_category_name
    title client_fqdn
    ymin 0
    ymax 100
    fields(
      :root_used => {
        :data => "asPercent(#{client_name}.df-root.df_complex-used.value, #{root_vol_size * 1000})",
        :alias => 'root_used'
      }
    )
  end
end
