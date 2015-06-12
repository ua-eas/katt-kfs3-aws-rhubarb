class Rhubarb::Driver
  # Namespace for several file utility methods for copying, moving, removing, etc.
  include FileUtils

  attr_accessor :logger, :status_timeout, :status_sleep

  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger

  # Rhubarb::Driver must be initialized with a job stream and a job name. This
  # means that an instance of the driver will only monitor the runfile and
  # statusfile of one instance of one job.
  #
  # When initialized, Driver will first validate that {#batch\_home} is valid,
  # via {Rhubarb.validate\_batch\_home}. Also, a {Rhubarb::Logger} is
  # immediately created, accessible via {#logger}.
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

    @status_timeout = 150.minutes
    @status_sleep = 5.seconds

    debug "batch_home:        #{Rhubarb.batch_home.inspect}"
    debug "control directory: #{Rhubarb.control_dir.inspect}"
    debug "job_base:          #{job_base.inspect}"
    debug "job_runfile:       #{job_runfile.inspect}"
    debug "job_statusfile:    #{job_statusfile.inspect}"
  end

  # Memoized getter for `@batch_home` (source is {Rhubarb.batch\_home})
  def batch_home
    @batch_home ||= Rhubarb.batch_home
  end

  def drive
    # TODO raise if already driven

    drop_runfile         # will raise if fail
    wait_for_statusfile  # will raise if fail
    if succeeded?           # true or false
      info "#{@job_name} succeeded:"
      info "> #{status_line}"
      return true
    else
      error "#{@job_name} did not succeed:"
      error "> #{status_line}"
      return false
    end
  end

  # Drops {#job\_runfile} into the filesystem and returns the {#job\_runfile}
  def drop_runfile
    begin
      touch job_runfile
    rescue Errno::EACCES => error
      error "Could not create run file: #{job_runfile.inspect}"
      raise Rhubarb::UnwritableControlDirectoryError
    end
    return job_runfile
  end

  # Works as the base for "runfiles" and "statusfiles":
  #
  # If `@job_name` is `"clearCacheJob"`, then this method will return
  # `"clearCacheJob_20120131120000"` if called at 12:00:00 on 2012-01-31. This
  # method is memoized so all subsequent calls will return the same String,
  # even if `Time.now` has changed.
  #
  # Equivalent to `BATCH_FILE_BASE` in BASIL
  def job_base
    @job_base ||= "#{@job_name}_#{Time.now.strftime('%Y%m%d%H%M%S')}"
  end

  # Memoized getter for this job's runfile name, full path included
  #
  # If:
  #
  # * {#batch\_home} is `"/transaction-kfs/"` and
  # * `@job_name` is `"clearCacheJob"` and
  # * {#job\_base} was called at 12:00:00 on 2012-01-31
  #
  # then this method will return
  # `"/transaction-kfs/control/clearCacheJob_20120131120000.run"`.
  #
  # @return [String] this job's runfile name
  def job_runfile
    @job_runfile ||= File.join(Rhubarb.control_dir, "#{job_base}.run")
  end

  # Memoized getter for this job's statusfile name, full path included
  #
  # If:
  #
  # * {#batch\_home} is `"/transaction-kfs/"` and
  # * `@job_name` is `"clearCacheJob"` and
  # * {#job\_base} was called at 12:00:00 on 2012-01-31
  #
  # then this method will return
  # `"/transaction-kfs/control/history/clearCacheJob_20120131120000.status"`.
  #
  # @return [String] this job's statusfile name
  def job_statusfile
    @job_statusfile ||= File.join(Rhubarb.control_dir, 'history', "#{job_base}.status")
  end

  # @return [String] the last line in the {#job\_statusfile}
  # @return nil if {#job\_statusfile} does not exist in the filesystem
  def status_line
    return nil if not File.exist? job_statusfile

    lines = File.readlines(job_statusfile)
    return nil if lines.last.nil?
    lines.last.chomp
  end

  # @return [Boolean] true if the {#status\_line} contains the substring
  #   "Succeeded"
  #
  # @return [Boolean] false otherwise
  def succeeded?
    return nil if status_line.nil?
    status_line.include? 'Succeeded'
  end

  # Waits for {#status\_timeout} seconds for both (A) the runfile to disappear
  # and (B) the statusfile to appear
  #
  # @raise [Rhubarb::StatusFileTimeoutError] if this method times out waiting
  #   for eaither (A) the runfile to disappear or (B) the statusfile to appear
  def wait_for_statusfile
    # TODO raise different exceptions
    # TODO refactor into two-ish methods
    deadline = Time.now + status_timeout
    info "Waiting for #{job_runfile.inspect}"
    info "Timeout is #{deadline} (#{status_timeout} seconds from now)."
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
    info "Statusfile found: #{job_statusfile}"
    job_statusfile
  end
end
