class Rhubarb::LogRoller
  def initialize
    Rhubarb.validate_batch_home
  end

  def batch_home
    @batch_home ||= Rhubarb.batch_home
  end

  def roll
    batch_logs = File.join(batch_home, 'logs')
    Dir.glob(File.join(batch_logs, '*.log')).each do |log_file|
      if log_file =~ /.*\/(.+)\.log$/
        base = $1
      else
        $stderr.puts "WARN: malformed log file: #{log_file}. Not rolling this one."
      end

      archive_dir = File.join(batch_logs, base)
      if not File.directory? archive_dir  # archive dir does not exist yet
        Dir.mkdir archive_dir
      end

      new_log_file = (Time.now-24*60*60).strftime("#{base}_%Y-%m-%d.log")
      FileUtils.move log_file, File.join(archive_dir, new_log_file)
    end
  end
end
