class Rhubarb::Driver
  # Namespace for several file utility methods for copying, moving, removing, etc.
  include FileUtils

  attr_accessor :logger, :status_timeout, :status_sleep

  delegate :debug, :info, :warn, :error, :fatal, to: :@logger

  def initialize(job_stream, job_name)
    Rhubarb.validate_batch_home

    @job_stream = job_stream
    @job_name = job_name

    @logger = Rhubarb::Logger.new(@job_stream)
    debug "Rhubarb::Driver initialized with job_stream = '#{job_stream}' and job_name = '#{job_name}'"

    if not File.directory? Rhubarb.control_dir
      error "'#{Rhubarb.control_dir}' directory does not exist, exiting."
      raise Rhubarb::MissingControlDirectoryError
    end

    @status_timeout = 3.hours
    @status_sleep = 5.seconds

    debug "batch_home:        #{Rhubarb.batch_home.inspect}"
    debug "control directory: #{Rhubarb.control_dir.inspect}"
    debug "job_base:          #{job_base.inspect}"
    debug "job_runfile:       #{job_runfile.inspect}"
    debug "job_statusfile:    #{job_statusfile.inspect}"
  end

  def batch_home
    @batch_home ||= Rhubarb.batch_home
  end

  def drop_runfile
    begin
      touch job_runfile
    rescue Errno::EACCES => error
      error "Could not create run file: #{job_runfile.inspect}"
      raise Rhubarb::UnwritableControlDirectoryError
    end
    return job_runfile
  end

  # Equivalent to BATCH_FILE_BASE in BASIL
  def job_base
    @job_base ||= "#{@job_name}_#{Time.now.strftime('%Y%m%d%H%M%S')}"
  end

  def job_runfile
    @job_runfile ||= File.join(Rhubarb.control_dir, "#{job_base}.run")
  end

  def job_statusfile
    @job_statusfile ||= File.join(Rhubarb.control_dir, 'history', "#{job_base}.status")
  end

  def wait_for_status_file
    deadline = Time.now + status_timeout
    loop do
      if (Time.now > deadline)
        # Consider chronic duration if we want to pretty print this:
        # https://github.com/hpoydar/chronic_duration#usage
        error "Runfile was never removed after #{status_timeout} seconds: #{job_runfile.inspect}"
        raise Rhubarb::StatusFileTimeoutError
      end
      # Move forward when the runfile disappears.
      break if not File.exist? job_runfile
      sleep status_sleep
    end

    loop do
      if (Time.now > deadline)
        error "Statusfile was never found after #{status_timeout} seconds: #{job_statusfile.inspect}"
        raise Rhubarb::StatusFileTimeoutError
      end
      # Move forward when the statusfile appears.
      break if File.exist? job_statusfile
      sleep status_sleep
    end

    # Huzzah status file
    job_statusfile
  end
end
