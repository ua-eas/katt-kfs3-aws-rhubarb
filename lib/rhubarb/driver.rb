class Rhubarb::Driver
  # Namespace for several file utility methods for copying, moving, removing, etc.
  include FileUtils

  def initialize(job_stream, job_name)
    Rhubarb.validate_batch_home

    @job_stream = job_stream
    @job_name = job_name
  end

  def batch_home
    @batch_home ||= Rhubarb.batch_home
  end

  def drop_runfile
    touch job_runfile
    return job_runfile
  end

  # Equivalent to BATCH_FILE_BASE in BASIL
  def job_base
    @job_base ||= "#{@job_name}_#{Time.now.strftime('%Y%m%d%H%M%S')}"
  end

  def job_runfile
    @job_runfile ||= File.join(Rhubarb.control_dir, "#{job_base}.run")
  end
end
