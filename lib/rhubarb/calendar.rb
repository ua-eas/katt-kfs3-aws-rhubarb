require 'icalendar'

# Rhubarb::Calendar manages Calendars generated from KFS Batch Job logs
class Rhubarb::Calendar
  include Icalendar

  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger

  def initialize()
    Rhubarb.validate_batch_home

    @logger = Rhubarb::Logger.new('calendar')
    debug "Rhubarb::Calendar initialized."
    @calendar = Calendar.new
  end

  def batch_home
    @batch_home ||= Rhubarb.batch_home
  end

  # 2012-10-25 06:50:06,344 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Executing job: JobDetail 'unscheduled.processPdpCancelsAndPaidJob':  jobClass: 'org.kuali.kfs.sys.batch.Job isStateful: true isVolatile: false isDurable: true requestsRecovers: false on machine uaz-kc-a50.mosaic.arizona.edu scheduler instance id uaz-kc-a50.mosaic.arizona.edu1351170014622. {status=Scheduled}
  # 2012-10-25 06:50:06,344 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Started processing step: 1=processPdpCancelsAndPaidStep for user <unknown>
  # 2012-10-25 06:50:06,348 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Creating user session for step: processPdpCancelsAndPaidStep=kfs-sys-user
  # 2012-10-25 06:50:06,348 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Executing step: processPdpCancelsAndPaidStep=class org.kuali.kfs.pdp.batch.ProcessPdPCancelsAndPaidStep
  # 2012-10-25 06:56:03,616 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Step processPdpCancelsAndPaidStep of unscheduled.processPdpCancelsAndPaidJob took 5.954466666666666 minutes to complete
  # 2012-10-25 06:56:03,616 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Finished processing step 1: processPdpCancelsAndPaidStep
  # 2012-10-25 06:56:03,616 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Finished executing job: processPdpCancelsAndPaidJob
  # 2012-10-25 06:56:03,616 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.service.impl.SchedulerServiceImpl :: Updating status of job: processPdpCancelsAndPaidJob=Succeeded
  # 2012-10-25 06:56:03,623 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.quartz.plugins.history.LoggingTriggerHistoryPlugin :: Trigger unscheduled.processPdpCancelsAndPaidJob completed firing job unscheduled.processPdpCancelsAndPaidJob at  06:56:03 10/25/2012 with resulting trigger instruction code: DELETE TRIGGER
  def event_from_log_lines(lines)
    lines = lines.split(/\n+/)
    event = @calendar.event do
      dtstart      Rhubarb::Calendar.timestamp_from_line(lines, "Executing job")
      dtend        Rhubarb::Calendar.timestamp_from_line(lines, "Finished executing job")
      summary      Rhubarb::Calendar.job_name(lines)
      description  lines.join('\n')
    end
  end

  def self.timestamp_from_line(lines, str)
    if lines.select { |l| l[str] }.first =~ /^([0-9\- :]+)/
      return DateTime.parse($1)
    else
      nil
    end
  end

  def self.job_name(lines)
    lines.select { |l| l =~ /Executing job: JobDetail 'unscheduled\.([^']*)'/ }.first =~ /Executing job: JobDetail 'unscheduled\.([^']*)'/
    $1
  end
end
