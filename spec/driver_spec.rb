require_relative 'spec_helper'

describe Rhubarb::Driver, '.new' do
  include Helpers

  before(:all) do
    cleanse_live
  end

  it 'should abandon ship without $BATCH_HOME' do
    Rhubarb.stub(:batch_home).and_return(nil)
    expect { Rhubarb::Driver.new('foo', 'bar') }.to raise_error(Rhubarb::MissingBatchHomeError)
  end

  it 'should abandon ship with an invalid $BATCH_HOME' do
    batch_home = File.join(@live_dir, 'uaf-fake')
    Rhubarb.stub(:batch_home).and_return(batch_home)
    expect { Rhubarb::Driver.new('foo', 'bar') }.to raise_error(Rhubarb::InvalidBatchHomeError)
  end

  it 'should abandon ship with an empty $BATCH_HOME directory' do
    batch_home = File.join(@live_dir, 'uaf-tst')
    Rhubarb.stub(:batch_home).and_return(batch_home)
    expect { Rhubarb::Driver.new('foo', 'bar') }.to raise_error(Rhubarb::EmptyBatchHomeError)
  end

  it 'should abandon ship without a control directory' do
    batch_home = File.join(@live_dir, 'uaf-cfg')
    Rhubarb.stub(:batch_home).and_return(batch_home)
    expect { Rhubarb::Driver.new('foo', 'bar') }.to raise_error(Rhubarb::MissingControlDirectoryError)
  end

  it 'should ERROR log the missing control directory' do
    Rhubarb.stub(:batch_home).and_return(@cfg_batch_home)
    begin
      driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    rescue => e
    end
    lines = File.readlines(File.join(Rhubarb.batch_home, 'logs', "einvoice.log"))
    lines.last.should match /[0-9:]{8} \(ERROR\) .*control.*/
  end

  it 'should initialize successfully' do
    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    expect { Rhubarb::Driver.new('einvoice', 'clearCacheJob') }.to_not raise_error
  end

  it 'should DEBUG log that it was initialized' do
    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    lines = File.readlines(driver.logger.job_stream_file)
    lines.should include_something_like /[0-9:]{8} \(DEBUG\) .*einvoice.*clearCacheJob/
  end

  it 'should DEBUG log various instance variables' do
    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    lines = File.readlines(driver.logger.job_stream_file)
    lines.should include_something_like /[0-9:]{8} \(DEBUG\) .*batch_home/
  end
end

describe Rhubarb::Driver, '#drop_runfile' do
  include Helpers

  before(:each) do
    cleanse_live

    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    @control_dir = File.join(@stg_batch_home, 'control')
  end

  it 'should raise if the runfile directory is not writable' do
    Rhubarb.stub(:batch_home).and_return(@trn_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    expect { @driver.drop_runfile }.to raise_error(Rhubarb::UnwritableControlDirectoryError)
  end

  it 'should ERROR log if the runfile directory is not writable' do
    Rhubarb.stub(:batch_home).and_return(@trn_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    begin
      @driver.drop_runfile
    rescue => error
    end
    lines = File.readlines(@driver.logger.job_stream_file)
    lines.should include_something_like /[0-9:]{8} \(ERROR\) .*Could not/
  end

  it 'should drop a runfile' do
    day_zero = Time.local(2012, 9, 1, 12, 00, 00)

    expected_runfile_name = nil
    Timecop.travel(day_zero) do
      expected_runfile_name = @driver.drop_runfile
    end
    latest_runfile = Dir.glob(File.join(@control_dir, '*.run')).sort_by { |runfile| File.mtime(runfile) }.last
    latest_runfile.should eq expected_runfile_name
  end
end

describe Rhubarb::Driver, '#wait_for_statusfile' do
  include Helpers

  before(:each) do
    cleanse_live

    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    @driver.status_timeout = 2
    @driver.status_sleep = 1
    @control_dir = File.join(@stg_batch_home, 'control')

    @day_zero = Time.local(2012, 9, 1, 12, 00, 00)
    @expected_runfile_name = nil
    Timecop.travel(@day_zero) do
      @expected_runfile_name = @driver.drop_runfile
    end
    @latest_runfile = Dir.glob(File.join(@control_dir, '*.run')).sort_by { |runfile| File.mtime(runfile) }.last
  end

  it 'should timeout and raise when no status file shows up' do
    expect { @driver.wait_for_statusfile }.to raise_error(Rhubarb::StatusFileTimeoutError)
  end

  it 'should INFO log when #wait_for_statusfile starts' do
    begin
      @driver.wait_for_statusfile
    rescue
    end

    lines = File.readlines(@driver.logger.job_stream_file)
    lines.should include_something_like /[0-9:]{8} \(INFO\) .*Waiting for/
  end

  it 'should ERROR log when no status file shows up' do
    begin
      @driver.wait_for_statusfile
    rescue
    end

    lines = File.readlines(@driver.logger.job_stream_file)
    lines.should include_something_like /[0-9:]{8} \(ERROR\) .*Runfile was never/
  end

  it 'should timeout and raise when the runfile doesn\'t leave, even if the status file shows up' do
    FileUtils.touch @driver.job_statusfile
    expect { @driver.wait_for_statusfile }.to raise_error(Rhubarb::StatusFileTimeoutError)
  end

  it 'should return the name of the statusfile when the runfile disappears and the statusfile appears _early_' do
    FileUtils.rm @driver.job_runfile
    FileUtils.touch @driver.job_statusfile
    @driver.wait_for_statusfile.should eq @driver.job_statusfile
  end

  it 'should return the name of the statusfile when the runfile disappears and the statusfile appears' do
    @driver.status_timeout = 6
    statusfile_waiter = Thread.new do
      @driver.wait_for_statusfile
    end

    sleep 2
    FileUtils.rm @driver.job_runfile

    sleep 2
    FileUtils.touch @driver.job_statusfile

    waiter_return = statusfile_waiter.value
    waiter_return.should eq @driver.job_statusfile
  end

  it 'should INFO log when the runfile disappears and the statusfile appears' do
    @driver.status_timeout = 4
    statusfile_waiter = Thread.new do
      @driver.wait_for_statusfile
    end

    sleep 1.5
    FileUtils.rm @driver.job_runfile

    sleep 1.5
    FileUtils.touch @driver.job_statusfile

    statusfile_waiter.join

    lines = File.readlines(@driver.logger.job_stream_file)
    lines.should include_something_like /[0-9:]{8} \(INFO\) .*Statusfile found/
  end
end

describe Rhubarb::Driver, '#status_line' do
  include Helpers

  before(:each) do
    cleanse_live

    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
  end

  it 'should return nil if there is no Statusfile' do
    @driver.status_line.should be nil
  end

  it 'should return nil if the Statusfile is empty' do
    FileUtils.touch @driver.job_statusfile
    @driver.status_line.should be nil
  end

  it 'should return the last line if the Statusfile is not empty' do
    File.open(@driver.job_statusfile, 'w') { |handle| handle.write("Line One\nLine 2\nLine Trois") }
    @driver.status_line.should eq "Line Trois"
  end

  it 'should return the last line if the Statusfile is not empty' do
    File.open(@driver.job_statusfile, 'w') { |handle| handle.write("Line One\nLine 2\nLine Trois\n") }
    @driver.status_line.should eq "Line Trois"
  end
end

describe Rhubarb::Driver, '#succeeded?' do
  include Helpers

  before(:each) do
    cleanse_live

    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
  end

  it 'should return nil if #status_line returns nil' do
    @driver.stub(:status_line).and_return(nil)
    @driver.succeeded?.should be nil
  end

  it 'should return true if #status_line returns "foo bar baz Succeeded bing bang bong"' do
    @driver.stub(:status_line).and_return("foo bar baz Succeeded bing bang bong")
    @driver.succeeded?.should be true
  end

  it 'should return false if #status_line returns "anything else here"' do
    @driver.stub(:status_line).and_return("anything else here")
    @driver.succeeded?.should be false
  end
end

describe Rhubarb::Driver, '#drive' do
  include Helpers

  before(:each) do
    cleanse_live

    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
  end

  it 'should return true if the job succeeded' do
    @driver.stub(:drop_runfile).and_return(true)
    @driver.stub(:wait_for_statusfile).and_return(true)
    @driver.stub(:status_line).and_return('I guess I... Succeeded!')
    @driver.stub(:succeeded?).and_return(true)
    @driver.drive.should be true
  end
end
