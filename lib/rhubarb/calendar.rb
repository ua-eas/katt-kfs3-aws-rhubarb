require 'icalendar'

# Rhubarb::Calendar manages Calendars generated from KFS Batch Job logs
class Rhubarb::Calendar
  include Icalendar

  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger

  def initialize()
    Rhubarb.validate_batch_home

    @logger = Rhubarb::Logger.new('calendar')
    debug "Rhubarb::Calendar initialized."
  end

  def batch_home
    @batch_home ||= Rhubarb.batch_home
  end

  def self.event_from_log_lines(lines)
  end
end
