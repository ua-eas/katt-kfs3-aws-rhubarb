require_relative 'spec_helper'

describe Rhubarb::Calendar, "#event_from_log_lines" do
  include Helpers

  before(:each) do
    cleanse_live
    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)

    @cal = Rhubarb::Calendar.new
    lines = <<LOGLINES
2012-10-25 06:50:06,344 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Executing job: JobDetail 'unscheduled.processPdpCancelsAndPaidJob':  jobClass: 'org.kuali.kfs.sys.batch.Job isStateful: true isVolatile: false isDurable: true requestsRecovers: false on machine uaz-kc-a50.mosaic.arizona.edu scheduler instance id uaz-kc-a50.mosaic.arizona.edu1351170014622. {status=Scheduled}
2012-10-25 06:50:06,344 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Started processing step: 1=processPdpCancelsAndPaidStep for user <unknown>
2012-10-25 06:50:06,348 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Creating user session for step: processPdpCancelsAndPaidStep=kfs-sys-user
2012-10-25 06:50:06,348 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Executing step: processPdpCancelsAndPaidStep=class org.kuali.kfs.pdp.batch.ProcessPdPCancelsAndPaidStep
2012-10-25 06:56:03,616 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Step processPdpCancelsAndPaidStep of unscheduled.processPdpCancelsAndPaidJob took 5.954466666666666 minutes to complete
2012-10-25 06:56:03,616 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Finished processing step 1: processPdpCancelsAndPaidStep
2012-10-25 06:56:03,616 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.Job :: Finished executing job: processPdpCancelsAndPaidJob
2012-10-25 06:56:03,616 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.kuali.kfs.sys.batch.service.impl.SchedulerServiceImpl :: Updating status of job: processPdpCancelsAndPaidJob=Succeeded
2012-10-25 06:56:03,623 KFS [KFSScheduler_Worker-3] u:/d: INFO  org.quartz.plugins.history.LoggingTriggerHistoryPlugin :: Trigger unscheduled.processPdpCancelsAndPaidJob completed firing job unscheduled.processPdpCancelsAndPaidJob at  06:56:03 10/25/2012 with resulting trigger instruction code: DELETE TRIGGER
LOGLINES
    @event = @cal.event_from_log_lines(lines)
  end

  it "should create an iCalendar event for a single job execution with a correct summary" do
    expect(@event.summary).to be =~ /processPdpCancelsAndPaidJob/
  end

  it "should create an iCalendar event for a single job execution with a correct dtstart" do
    expect(@event.dtstart).to be == DateTime.new(2012, 10, 25, 6, 50, 06)
  end

  it "should create an iCalendar event for a single job execution with a correct dtend" do
    expect(@event.dtend).to be == DateTime.new(2012, 10, 25, 6, 56, 03)
  end
end
