module MobME::Enterprise::TvChannelInfo
  class Service < MobME::Infrastructure::RPC::Base
    def initialize
      database_configuration_path =  File.expand_path(File.dirname(__FILE__)) + "/../../../../database.yml"
      database_configuration = YAML.load(database_configuration_path)
      ActiveRecord::Base.establish_connection(database_configuration)
    end

    def channels
      channels = Channel.all
      channel_info = {}
      channels.each do |channel|
        channel_info[channel.id] = channel.name
      end
      channel_info
    end

    def programs_for_channel(channel_id)
      air_time = Time.now.utc
      programs = Program.where("channel_id = :channel_id and air_time like ':air_time%'", {:channel_id => 1, :air_time_start => air_time.strftime("%Y-%m-%d")})
      program_info = {}
      programs.each do |program|
        program_info[program.id] = {:name => program.name, :category_id => program.category_id, :series_id => program.series_id,:air_time_start => program.air_time_start}
      end
      program_info
    end
  end
end