class Rhubarb::Driver
  # Namespace for several file utility methods for copying, moving, removing, etc.
  include FileUtils

  attr_accessor :status_timeout, :status_sleep

  def initialize(job_stream, job_name)
    Rhubarb.validate_batch_home

    @job_stream = job_stream
    @job_name = job_name

    @status_timeout = 3.hours
    @status_sleep = 5.seconds
  end

  def batch_home
    @batch_home ||= Rhubarb.batch_home
  end

  def drop_runfile
    begin
      touch job_runfile
    rescue Errno::EACCES => error
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
        raise Rhubarb::StatusFileTimeoutError
      end
      # Move forward when the runfile disappears.
      break if not File.exist? job_runfile
      sleep status_sleep
    end

    loop do
      if (Time.now > deadline)
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
