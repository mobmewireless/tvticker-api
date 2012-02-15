$LOAD_PATH.unshift File.expand_path("../../../lib", __FILE__)
require "bundler/setup"
require "rpc"
require "mobme-infrastructure-rpc"
RPC.logging = true
client = RPC::Client.setup("http://127.0.0.1:3000/service")
begin
  hash = client.update_to_current_version
  p "-------------------------------"

p hash["programs"]
#hash.each{|e| p e}
rescue MobME::Infrastructure::RPC::Error => exception
  STDERR.puts "EXCEPTION CAUGHT: #{exception.inspect}"
end


