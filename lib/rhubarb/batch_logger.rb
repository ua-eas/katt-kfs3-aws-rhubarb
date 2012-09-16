class Rhubarb::BatchLogger
  include Log4r

  attr_accessor :job_stream_file, :log4r_logger

  delegate :debug, :info, :warn, :error, :fatal, to: :@log4r_logger

  def initialize(job_stream)
    raise Rhubarb::MissingBatchHomeError if batch_home.nil?
    raise Rhubarb::InvalidBatchHomeError if not File.exist? batch_home
    batch_home_entries = Dir.new(batch_home).entries.reject {|e| e =~ /\.+|placeholder.txt/}
    raise Rhubarb::EmptyBatchHomeError if batch_home_entries.empty?
    @job_stream_file = File.join(batch_home, 'logs', "#{job_stream}.log")

    @log4r_logger = Logger.new 'job_stream_logger'
    job_stream_file_outputter = FileOutputter.new('fileOutputter', :filename => @job_stream_file)
    @short_formatter = PatternFormatter.new(:pattern => "%d (%l) %m", :date_pattern => "%H:%M:%S")
    @long_formatter  = PatternFormatter.new(:pattern => "%d %m", :date_pattern => "%a, %d %b %Y %H:%M:%S %z")
    job_stream_file_outputter.formatter = @short_formatter
    @log4r_logger.add(job_stream_file_outputter)
  end

  def batch_home
    @batch_home ||= Rhubarb::BatchLogger.batch_home
  end

  # This part was purely to allow me to mock the instance method. I don't like
  # this but there it is.
  def self.batch_home
    ENV['BATCH_HOME']
  end

  def h1(message)
    info("# #{message}")
  end

  def h2(message)
    info("## #{message}")
  end

  def h3(message)
    info("### #{message}")
  end

  def h4(message)
    info("#### #{message}")
  end

  def h5(message)
    info("##### #{message}")
  end

  def stamp(message)
    @log4r_logger.remove(@job_stream_file_outputter)
    outputter = FileOutputter.new('fileOutputter', :filename => @job_stream_file)
    outputter.formatter = @long_formatter
    @log4r_logger.add(outputter)
    info(message)
    outputter = FileOutputter.new('fileOutputter', :filename => @job_stream_file)
    outputter.formatter = @short_formatter
    @log4r_logger.add(outputter)
  end
end
