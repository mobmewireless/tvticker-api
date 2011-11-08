# Standard
require 'yaml'

# Gems
require 'mobme-infrastructure-rpc'
require 'active_record'
require 'active_support/all'

# Local
require_relative 'mobme/enterprise/tv_channel_info/version'
require_relative 'mobme/enterprise/tv_channel_info/models'
require_relative 'mobme/enterprise/tv_channel_info/service'
#MobME::Infrastructure::RPC::Runner.start Application.new, '0.0.0.0', 8080, '/test_application'