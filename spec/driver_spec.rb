require_relative 'spec_helper'

describe Rhubarb::Driver, '.new' do
  include Helpers

  before(:all) do
    cleanse_live
  end

  it 'should abandon ship without $BATCH_HOME' do
    allow(Rhubarb).to receive(:batch_home).and_return(nil)
    expect { Rhubarb::Driver.new('foo', 'bar') }.to raise_error(Rhubarb::MissingBatchHomeError)
  end

  it 'should abandon ship with an invalid $BATCH_HOME' do
    batch_home = File.join(@live_dir, 'uaf-fake')
    allow(Rhubarb).to receive(:batch_home).and_return(batch_home)
    expect { Rhubarb::Driver.new('foo', 'bar') }.to raise_error(Rhubarb::InvalidBatchHomeError)
  end

  it 'should abandon ship with an empty $BATCH_HOME directory' do
    batch_home = File.join(@live_dir, 'uaf-tst')
    allow(Rhubarb).to receive(:batch_home).and_return(batch_home)
    expect { Rhubarb::Driver.new('foo', 'bar') }.to raise_error(Rhubarb::EmptyBatchHomeError)
  end

  it 'should abandon ship without a control directory' do
    batch_home = File.join(@live_dir, 'uaf-cfg')
    allow(Rhubarb).to receive(:batch_home).and_return(batch_home)
    expect { Rhubarb::Driver.new('foo', 'bar') }.to raise_error(Rhubarb::MissingControlDirectoryError)
  end

  it 'should ERROR log the missing control directory' do
    allow(Rhubarb).to receive(:batch_home).and_return(@cfg_batch_home)
    begin
      driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    rescue => e
    end
    lines = File.readlines(File.join(Rhubarb.batch_home, 'logs', "einvoice.log"))
    expect(lines.last).to match /[0-9:]{8} \(ERROR\) .*control.*/
  end

  it 'should initialize successfully' do
    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    expect { Rhubarb::Driver.new('einvoice', 'clearCacheJob') }.to_not raise_error
  end

  it 'should DEBUG log that it was initialized' do
    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    lines = File.readlines(driver.logger.job_stream_file)
    expect(lines).to include_something_like /[0-9:]{8} \(DEBUG\) .*einvoice.*clearCacheJob/
  end

  it 'should DEBUG log various instance variables' do
    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    lines = File.readlines(driver.logger.job_stream_file)
    expect(lines).to include_something_like /[0-9:]{8} \(DEBUG\) .*batch_home/
  end
end

describe Rhubarb::Driver, '#drop_runfile' do
  include Helpers

  before(:each) do
    cleanse_live

    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    @control_dir = File.join(@stg_batch_home, 'control')
  end

  it 'should raise if the runfile directory is not writable' do
    allow(Rhubarb).to receive(:batch_home).and_return(@trn_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    expect { @driver.drop_runfile }.to raise_error(Rhubarb::UnwritableControlDirectoryError)
  end

  it 'should ERROR log if the runfile directory is not writable' do
    allow(Rhubarb).to receive(:batch_home).and_return(@trn_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    begin
      @driver.drop_runfile
    rescue => error
    end
    lines = File.readlines(@driver.logger.job_stream_file)
    expect(lines).to include_something_like /[0-9:]{8} \(ERROR\) .*Could not/
  end

  it 'should drop a runfile' do
    day_zero = Time.local(2012, 9, 1, 12, 00, 00)

    expected_runfile_name = nil
    Timecop.travel(day_zero) do
      expected_runfile_name = @driver.drop_runfile
    end
    latest_runfile = Dir.glob(File.join(@control_dir, '*.run')).sort_by { |runfile| File.mtime(runfile) }.last
    expect(latest_runfile).to eq expected_runfile_name
  end
end

describe Rhubarb::Driver, '#wait_for_statusfile' do
  include Helpers

  before(:each) do
    cleanse_live

    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    @driver.status_timeout = 10
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
    expect(lines).to include_something_like /[0-9:]{8} \(INFO\) .*Waiting for/
  end

  it 'should ERROR log when no status file shows up' do
    begin
      @driver.wait_for_statusfile
    rescue
    end

    lines = File.readlines(@driver.logger.job_stream_file)
    expect(lines).to include_something_like /[0-9:]{8} \(ERROR\) .*Runfile was never/
  end

  it 'should timeout and raise when the runfile doesn\'t leave, even if the status file shows up' do
    FileUtils.touch @driver.job_statusfile
    expect { @driver.wait_for_statusfile }.to raise_error(Rhubarb::StatusFileTimeoutError)
  end

  it 'should return the name of the statusfile when the runfile disappears and the statusfile appears _early_' do
    FileUtils.rm @driver.job_runfile
    FileUtils.touch @driver.job_statusfile
    expect(@driver.wait_for_statusfile).to eq @driver.job_statusfile
  end

  it 'should return the name of the statusfile when the runfile disappears and the statusfile appears' do
    statusfile_waiter = Thread.new do
      @driver.wait_for_statusfile
    end

    sleep 2
    FileUtils.rm @driver.job_runfile

    sleep 2
    FileUtils.touch @driver.job_statusfile

    waiter_return = statusfile_waiter.value
    expect(waiter_return).to eq @driver.job_statusfile
  end

  it 'should INFO log when the runfile disappears and the statusfile appears' do
    statusfile_waiter = Thread.new do
      @driver.wait_for_statusfile
    end

    sleep 1.5
    FileUtils.rm @driver.job_runfile

    sleep 1.5
    FileUtils.touch @driver.job_statusfile

    statusfile_waiter.join

    lines = File.readlines(@driver.logger.job_stream_file)
    expect(lines).to include_something_like /[0-9:]{8} \(INFO\) .*Statusfile found/
  end
end

describe Rhubarb::Driver, '#status_line' do
  include Helpers

  before(:each) do
    cleanse_live

    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
  end

  it 'should return nil if there is no Statusfile' do
    expect(@driver.status_line).to be nil
  end

  it 'should return nil if the Statusfile is empty' do
    FileUtils.touch @driver.job_statusfile
    expect(@driver.status_line).to be nil
  end

  it 'should return the last line if the Statusfile is not empty' do
    File.open(@driver.job_statusfile, 'w') { |handle| handle.write("Line One\nLine 2\nLine Trois") }
    expect(@driver.status_line).to eq "Line Trois"
  end

  it 'should return the last line if the Statusfile is not empty' do
    File.open(@driver.job_statusfile, 'w') { |handle| handle.write("Line One\nLine 2\nLine Trois\n") }
    expect(@driver.status_line).to eq "Line Trois"
  end
end

describe Rhubarb::Driver, '#succeeded?' do
  include Helpers

  before(:each) do
    cleanse_live

    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
  end

  it 'should return nil if #status_line returns nil' do
    allow(@driver).to receive(:status_line).and_return(nil)
    expect(@driver.succeeded?).to be nil
  end

  it 'should return true if #status_line returns "foo bar baz Succeeded bing bang bong"' do
    allow(@driver).to receive(:status_line).and_return("foo bar baz Succeeded bing bang bong")
    expect(@driver.succeeded?).to be true
  end

  it 'should return false if #status_line returns "anything else here"' do
    allow(@driver).to receive(:status_line).and_return("anything else here")
    expect(@driver.succeeded?).to be false
  end
end

describe Rhubarb::Driver, '#drive' do
  include Helpers

  before(:each) do
    cleanse_live

    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
  end

  it 'should return true if the job succeeded' do
    allow(@driver).to receive(:drop_runfile).and_return(true)
    allow(@driver).to receive(:wait_for_statusfile).and_return(true)
    allow(@driver).to receive(:status_line).and_return('I guess I... Succeeded!')
    allow(@driver).to receive(:succeeded?).and_return(true)
    expect(@driver.drive).to be true
  end
end
