module MobME::Enterprise::ImageProcessing

  class ThumbnailGenerator< MobME::Infrastructure::Service::Worker
    service_name = "mobme.enterprise.imageprocessing.thumbnailgenerator"

    class << self;
      attr_reader :required_keys;
    end

    # Three keys - 'message', 'to', and 'application_name' are minimum for a valid job.
    @required_keys = ['original_link']

    # Merely calls super-class's initialize method.
    def initialize
      $stdout.sync = true
      super
    end

    # Infinite loop, which attempts to remove jobs from the queue at one-second intervals.
    def work_loop
      while (1) do
        queue.remove(self.class.service_name) do |job|
          begin
            process_job(job[0])
          rescue => e
            logger.error "#{e.message} | BACKTRACE: #{e.backtrace}"
            raise e
          end
        end
        sleep(1)
      end
    end

    # Loads configuration, subscribes to queue, and logs / re-raises errors thrown while processing the job.
    def work
      configuration_yaml_path = File.expand_path("#{File.dirname(__FILE__)}/../../../../../db/config.yml")
      configuration = MobME::Infrastructure::Configurdation.load_using_file(configuration_yaml_path)
      @configuration = configuration[self.class.service_name]
      # Untested JSON parsing done here. This is because we expect configuration to return a Hash, not a string.
      logger.info "Listening on queue with service name #{self.class.service_name}..."
      work_loop
    end

  end

# processes job
#@param [Hash]
  def process_job(job)
    logger.debug "Received job."
    unless valid_job?(job)
      logger.warn "Job was invalid. Skipping: #{job.inspect}"
      return
    end
    logger.info "Received valid job from queue."

    job_config = @broadcast_configuration['application_routing'][job['application_name']]

    unless job_config
      logger.warn "Job was valid, but configuration was not. Skipping... Config: #{job_config.inspect}"
      return
    end

    t = MobME::Enterprise::TvChannelInfo::Thumbnail.find_by_status("pending")
    t.remote_image_url = t.original_link
    t.status ="processed"
    t.save

  end

  # Checks whether submitted job contains all mandatory parameters.
  def valid_job?(job)
    self.class.required_keys.all? { |key| job.has_key?(key) }
  end

end