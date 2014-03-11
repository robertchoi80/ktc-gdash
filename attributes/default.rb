include_attribute 'gdash::gdash'
include_attribute 'graphite::default'

default[:gdash][:columns] = 3
default[:gdash][:monitor_client_recipe] = 'ktc-base'
