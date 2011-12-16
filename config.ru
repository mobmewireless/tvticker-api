require "bundler/setup"

require "mobme-infrastructure-rpc"

require "#{File.expand_path(File.dirname(__FILE__))}/lib/mobme/enterprise/mobme-enterprise-tv-channel-info"

map("/service") do

  RPC.logging= true
  run MobME::Infrastructure::RPC::Adaptor.new(MobME::Enterprise::TvChannelInfo::Service.new)

end