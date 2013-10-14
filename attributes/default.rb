include_attribute "gdash::gdash"

default[:gdash][:graphite_host] = "vim-monitor01-vm.mkd-stag"
default[:gdash][:graphite_url] = "http://#{node[:gdash][:graphite_host]}:#{graphite[:listen_port]}"
default[:gdash][:monitor_client_recipe] = "ktc-base"
