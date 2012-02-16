require "bundler/setup"

require "mobme-infrastructure-rpc"

require "#{File.expand_path(File.dirname(__FILE__))}/lib/mobme/enterprise/mobme-enterprise-tv-channel-info"

class AllowCrossOriginMiddleware
  # Simple middleware for adding cross origin headers
  def initialize(app, allowed_origins=['*'])
    @app = app
    @allowed_origins = allowed_origins
  end

  def call(env, *args)
    request = Rack::Request.new(env)
    headers = {
      'Access-Control-Allow-Origin' => @allowed_origins.join(', '),
      'Access-Control-Allow-Methods' => 'POST, GET, OPTIONS',
      'Access-Control-Max-Age' => '1000',
      'Access-Control-Allow-Headers' => 'Content-type'
    }
    if 'OPTIONS' == request.request_method 
      [200, headers, ""]
    else
      status, response_headers, response = @app.call(env)
      [status, response_headers.merge(headers), response]
    end
  end
end


map("/service") do
  RPC.logging= true
  use AllowCrossOriginMiddleware
  run(MobME::Infrastructure::
      RPC::Adaptor.new(MobME::Enterprise::TvChannelInfo::Service.new))
end
