class Rhubarb::Logger
  include Log4r

  attr_accessor :job_stream_file, :log4r_logger

  delegate :debug, :info, :warn, :error, :fatal, to: :@log4r_logger

  # Create a new Rhubarb::Logger that will initially log to `$BATCH_HOME/logs/job_stream.log`.
  def initialize(job_stream)
    Rhubarb.validate_batch_home
    @job_stream_file = File.join(batch_home, 'logs', "#{job_stream}.log")

    @log4r_logger = Logger.new 'job_stream_logger'
    job_stream_file_outputter = FileOutputter.new('fileOutputter', :filename => @job_stream_file)
    @time_formatter  = PatternFormatter.new(:pattern => "%d (%l) %m", :date_pattern => "%H:%M:%S")
    @short_formatter = PatternFormatter.new(:pattern => "%d (%l) %m", :date_pattern => "%Y-%m-%d %H:%M:%S")
    @long_formatter  = PatternFormatter.new(:pattern => "%d %m", :date_pattern => "%a, %d %b %Y %H:%M:%S %z")
    job_stream_file_outputter.formatter = @time_formatter
    @log4r_logger.add(job_stream_file_outputter)
  end

  def batch_home
    @batch_home ||= Rhubarb.batch_home
  end

  # Log a markdown-formatted H1 header
  def h1(message)
    info("# #{message}")
  end

  # Log a markdown-formatted H2 header
  def h2(message)
    info("## #{message}")
  end

  # Log a markdown-formatted H3 header
  def h3(message)
    info("### #{message}")
  end

  # Log a markdown-formatted H4 header
  def h4(message)
    info("#### #{message}")
  end

  # Log a markdown-formatted H5 header
  def h5(message)
    info("##### #{message}")
  end

  # Log a markdown-formatted H6 header
  def h6(message)
    info("###### #{message}")
  end

  def log_to_stdout
    job_stream_stdout_outputter = StdoutOutputter.new('console')
    job_stream_stdout_outputter.formatter = @short_formatter
    @log4r_logger.add(job_stream_stdout_outputter)
  end

  def stamp(message)
    @log4r_logger.remove(@job_stream_file_outputter)
    outputter = FileOutputter.new('fileOutputter', :filename => @job_stream_file)
    outputter.formatter = @long_formatter
    @log4r_logger.add(outputter)
    info(message)
    outputter = FileOutputter.new('fileOutputter', :filename => @job_stream_file)
    outputter.formatter = @time_formatter
    @log4r_logger.add(outputter)
  end
end
