module MobME::Enterprise::TvChannelInfo
  class FrameTypeError < StandardError
  end

  class Service < MobME::Infrastructure::RPC::Base

    def initialize
      database_configuration_file = File.read File.expand_path(File.dirname(__FILE__)) + "/../../../../db/config.yml"
      database_configuration = YAML.load(database_configuration_file)
      database_configuration = database_configuration["development"]
      ActiveRecord::Base.establish_connection(database_configuration)
    end

    def am_i_live
      "yes"
    end

    def channels
      channels = Channel.all
      channel_info = {}
      channels.each do |channel|
        channel_info[channel.id] = channel.name
      end
      channel_info
    end

    def categories
      categories = Category.all
    end

    def programs_for_channel(channel_id)
      air_time_start = Time.now.utc
      programs = Program.where("channel_id = :channel_id and air_time_start like :air_time_start ", {:channel_id => channel_id, :air_time_start =>"#{air_time_start.strftime("%Y-%m-%d").to_s}%"})
      program_info = {}
      programs.each do |program|
        program_info[program.id] = {:name => program.name, :category_id => program.category_id, :series_id => program.series_id, :air_time_start => program.air_time_start}
      end
      program_info
    end

    def programs_for_current_frame(from_time, frame_type)
      from_time = Time.parse(from_time.to_s);
      if frame_type==:now or frame_type == "now"
        Program.where(" air_time_start between :air_time_start and :air_time_end", {:air_time_start =>from_time-60*60, :air_time_end =>(from_time+60*60)})
      elsif frame_type==:later or frame_type == "later"
        Program.where(" air_time_start between :air_time_start and :air_time_end", {:air_time_start =>from_time+60*60, :air_time_end =>(from_time+3*60*60)})
      elsif frame_type==:full or frame_type == "full"
         Program.where(" air_time_start > :air_time_start ", {:air_time_start =>from_time})
      else
        raise FrameTypeError, "incorrect frame type"
      end
    end

    def generate_thumbnail()
      t = Thumbnail.new
      t.original_link = "http://images2.fanpop.com/images/photos/3900000/Natalie-Portman-natalie-portman-3947071-1413-1229.jpg"
      t.status = "pending"
      t.save
    end

  end

end
