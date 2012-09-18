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

  it 'should initialize successfully' do
    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    expect { Rhubarb::Driver.new('einvoice', 'clearCacheJob') }.to_not raise_error
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

describe Rhubarb::Driver, '#wait_for_status_file' do
  include Helpers

  before(:each) do
    cleanse_live

    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    @driver = Rhubarb::Driver.new('einvoice', 'clearCacheJob')
    @driver.status_timeout = 2
    @driver.status_sleep = 1
    @control_dir = File.join(@stg_batch_home, 'control')

    @day_zero = Time.local(2012, 9, 1, 12, 00, 00)
  end

  it 'should timeout and raise when no status file shows up' do
    expected_runfile_name = nil
    Timecop.travel(@day_zero) do
      expected_runfile_name = @driver.drop_runfile
    end
    latest_runfile = Dir.glob(File.join(@control_dir, '*.run')).sort_by { |runfile| File.mtime(runfile) }.last
    expect { @driver.wait_for_status_file }.to raise_error(Rhubarb::StatusFileTimeoutError)
  end

  it 'should timeout and raise when the runfile doesn\'t leave, even if the status file shows up' do
    expected_runfile_name = nil
    Timecop.travel(@day_zero) do
      expected_runfile_name = @driver.drop_runfile
    end
    latest_runfile = Dir.glob(File.join(@control_dir, '*.run')).sort_by { |runfile| File.mtime(runfile) }.last
    FileUtils.touch @driver.job_statusfile
    expect { @driver.wait_for_status_file }.to raise_error(Rhubarb::StatusFileTimeoutError)
  end

  it 'should return the name of the statusfile when the runfile disappears and the statusfile appears _early_' do
    expected_runfile_name = nil
    Timecop.travel(@day_zero) do
      expected_runfile_name = @driver.drop_runfile
    end
    latest_runfile = Dir.glob(File.join(@control_dir, '*.run')).sort_by { |runfile| File.mtime(runfile) }.last
    FileUtils.rm @driver.job_runfile
    FileUtils.touch @driver.job_statusfile
    @driver.wait_for_status_file.should eq @driver.job_statusfile
  end

  it 'should return the name of the statusfile when the runfile disappears and the statusfile appears' do
    expected_runfile_name = nil
    Timecop.travel(@day_zero) do
      expected_runfile_name = @driver.drop_runfile
    end
    latest_runfile = Dir.glob(File.join(@control_dir, '*.run')).sort_by { |runfile| File.mtime(runfile) }.last

    @driver.status_timeout = 6
    statusfile_waiter = Thread.new do
      @driver.wait_for_status_file
    end

    sleep 2
    FileUtils.rm @driver.job_runfile

    sleep 2
    FileUtils.touch @driver.job_statusfile

    waiter_return = statusfile_waiter.value
    waiter_return.should eq @driver.job_statusfile
  end
end
