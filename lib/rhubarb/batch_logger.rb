class Rhubarb::BatchLogger
  include Log4r

  attr_accessor :log4r_logger

  delegate :info, :error, to: :@log4r_logger

  def initialize(job_stream)
    raise Rhubarb::MissingBatchHomeError if batch_home.nil?
    raise Rhubarb::InvalidBatchHomeError if not File.exist? batch_home
    batch_home_entries = Dir.new(batch_home).entries.reject {|e| e =~ /\.+|placeholder.txt/}
    raise Rhubarb::EmptyBatchHomeError if batch_home_entries.empty?
    @job_stream_file = File.join(batch_home, job_stream)

    @log4r_logger = Logger.new 'job_stream_logger'
  end

  def batch_home
    @batch_home ||= Rhubarb::BatchLogger.batch_home
  end

  # This part was purely to allow me to mock the instance method. I don't like
  # this but there it is.
  def self.batch_home
    ENV['BATCH_HOME']
  end
end
