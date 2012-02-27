module MobME::Enterprise::TvChannelInfo
  class FrameTypeError < StandardError
  end

  class AuthenticationError < StandardError
  end

  class Service < MobME::Infrastructure::RPC::Base
    attr_accessor :logger

    def initialize
      establish_connection
      establish_logging
      load_keys

      #logger.info "Starting up!"
    end

    def ping(timestamp, key)
      authenticate_credentials(timestamp, key)

      logger.info "Received ping"
      "pong"
    rescue MobME::Enterprise::TvChannelInfo::AuthenticationError
      ""
    end

    def channels(timestamp, key)
      authenticate_credentials(timestamp, key)

      logger.info "Received channels"
      channels = Channel.select(Channel.column_names - ["version_id"])
    rescue MobME::Enterprise::TvChannelInfo::AuthenticationError
      {}
    end

    def categories(timestamp, key)
      authenticate_credentials(timestamp, key)

      logger.info "Received categories"
      Category.select(Category.column_names - ["version_id"])
    rescue MobME::Enterprise::TvChannelInfo::AuthenticationError
      {}
    end

    def programs_for_channel(timestamp, key, channel_id)
      authenticate_credentials(timestamp, key)

      logger.info "Received programs_for_channel(#{channel_id})"
      air_time_start = Time.now.utc
      Program.select(Program.column_names - ["version_id"]).where("channel_id = :channel_id and air_time_start like :air_time_start ", {:channel_id => channel_id, :air_time_start =>"#{air_time_start.strftime("%Y-%m-%d").to_s}%"})
    rescue MobME::Enterprise::TvChannelInfo::AuthenticationError
      {}
    end

    def programs_for_current_frame(timestamp, key, from_time, frame_type)
      authenticate_credentials(timestamp, key)

      logger.info "Received programs_for_current_frame(#{from_time}, #{frame_type})"
      time = time_hash_for(from_time, frame_type.to_sym)
      logger.info time
      return Program.select(Program.column_names - ["version_id"]).where("air_time_start between :air_time_start and :air_time_end and air_time_end > :end_time", time) if frame_type.to_sym == :now or frame_type.to_sym == :later
      return Program.select(Program.column_names - ["version_id"]).where("air_time_start > :air_time_start or :air_time_end > :air_time_start", time) if frame_type.to_sym == :full
      raise FrameTypeError, "incorrect frame type"
    rescue MobME::Enterprise::TvChannelInfo::AuthenticationError
      {}
    end

    def current_frame_full_data(timestamp, key, from_time, frame_type, count=nil)
      authenticate_credentials(timestamp, key)

      logger.info "Received programs_for_current_frame(#{from_time}, #{frame_type})"
      time = time_hash_for(from_time, frame_type.to_sym)
      logger.info time

      programs =
          case frame_type.to_sym
            when :now, :later
              Program.where("air_time_start between :air_time_start and :air_time_end and air_time_end > :end_time", time)
            when :full
              Program.where("air_time_start > :air_time_start or :air_time_end > :air_time_start", time)
            else
              raise FrameTypeError, "incorrect frame type"
          end
      programs.order(:air_time_start).limit(count).map do |p|
        p.as_json(:except => [:version_id], :include => [:category, :channel])
      end
    rescue MobME::Enterprise::TvChannelInfo::AuthenticationError
      {}
    end

    def current_version(timestamp, key)
      authenticate_credentials(timestamp, key)

      logger.info "Received current_version"

      Version.last.number rescue ""
    rescue MobME::Enterprise::TvChannelInfo::AuthenticationError
      ""
    end

    def update_to_current_version_except_programs(timestamp, key, client_version = "")
      authenticate_credentials(timestamp, key)

      logger.info "Received update_to_current_version(#{client_version})"

      client_version_number = Version.find_by_number(client_version)[:id] rescue 0
      {
          :channels => Channel.version_greater_than(client_version_number),
          :categories => Category.version_greater_than(client_version_number),
          :series => Series.version_greater_than(client_version_number),
          :versions => Version.version_greater_than(client_version_number)
      }
    rescue MobME::Enterprise::TvChannelInfo::AuthenticationError
      {}
    end

    def update_programs_to_current_version(timestamp, key, client_version = "", days = 7)
      authenticate_credentials(timestamp, key)

      logger.info "Received update_programs_to_current_version"
      client_version_number = Version.find_by_number(client_version)[:id] rescue 0
      latest_version_number = Program.latest_version(client_version_number,days).first.version.number rescue client_version
      programs = Program.version_greater_than_ordered(client_version_number,days)
      {
          :programs => Program.version_greater_than_ordered(client_version_number,days),
          :version =>  latest_version_number
      }
    rescue MobME::Enterprise::TvChannelInfo::AuthenticationError
      {}
    end

    def now_showing(timestamp, key, count=nil)
      authenticate_credentials(timestamp, key)
      programs = Program.
          where("current_time BETWEEN air_time_start AND air_time_end").
          order('air_time_start').
          limit(count)
      programs.map do |p|
        p.as_json(
            :except => [:version_id],
            :include => [:category, :channel]
        )['program']
      end
    end

    private

    def time_hash_for(from_time, frame_type)
      logger.info "Received time_hash_for(#{from_time}, #{frame_type})"
      from_time = DateTime.parse(from_time.to_s).in_time_zone("UTC")
      case frame_type
        when :now
          {:air_time_start =>from_time -60*60, :air_time_end =>(from_time+60*60), :end_time => from_time}
        when :later
          {:air_time_start =>from_time+60*60, :air_time_end =>(from_time+3*60*60), :end_time => from_time + 60*60}
        when :full
          {:air_time_start =>from_time}
        else
          nil
      end
    end

    def authenticate_credentials(timestamp, hashed_key)
      key_found = @keys.any? do |key|
        Digest::MD5.hexdigest("#{timestamp}#{key}") == hashed_key
      end

      raise MobME::Enterprise::TvChannelInfo::AuthenticationError unless key_found
    end

    def establish_connection
      database_configuration_file = File.read File.expand_path(File.dirname(__FILE__)) + "/../../../../config/database.yml"
      database_configuration = YAML.load(database_configuration_file)
      database_configuration = database_configuration[ENV["RACK_ENV"] || "development"]
      ActiveRecord::Base.establish_connection(database_configuration)
      ActiveRecord::Base.default_timezone= :utc
    end

    def establish_logging
      log_file = File.expand_path(File.dirname(__FILE__)) + "/../../../../log/api.log"
      @logger = Logger.new(log_file)
      ActiveRecord::Base.logger = @logger
    end

    def load_keys
      key_file = File.expand_path(File.dirname(__FILE__)) + "/../../../../config/keys.yml"
      @keys = YAML.load_file(key_file).values

      logger.debug "@keys = #{@keys.inspect}"
    end
  end
end
