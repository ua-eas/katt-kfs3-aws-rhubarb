require_relative 'spec_helper'

describe Rhubarb::BatchDriver, '.new' do
  include Helpers

  before(:all) do
    cleanse_live
  end

  it 'should abandon ship without $BATCH_HOME' do
    Rhubarb::BatchDriver.stub(:batch_home).and_return(nil)
    expect { Rhubarb::BatchDriver.new }.to raise_error(Rhubarb::MissingBatchHomeError)
  end

  it 'should abandon ship with an invalid $BATCH_HOME' do
    batch_home = File.join(@live_dir, 'uaf-fake')
    Rhubarb::BatchDriver.stub(:batch_home).and_return(batch_home)
    expect { Rhubarb::BatchDriver.new }.to raise_error(Rhubarb::InvalidBatchHomeError)
  end

  it 'should abandon ship with an empty $BATCH_HOME directory' do
    batch_home = File.join(@live_dir, 'uaf-tst')
    Rhubarb::BatchDriver.stub(:batch_home).and_return(batch_home)
    expect { Rhubarb::BatchDriver.new }.to raise_error(Rhubarb::EmptyBatchHomeError)
  end

  it 'should initialize successfully' do
    Rhubarb::BatchDriver.stub(:batch_home).and_return(@stg_batch_home)
    expect { Rhubarb::BatchDriver.new('einvoice', 'clearCacheJob') }.to_not raise_error
  end
end

describe Rhubarb::BatchDriver, '#drop_runfile' do
  include Helpers

  before(:each) do
    cleanse_live

    Rhubarb::BatchDriver.stub(:batch_home).and_return(@stg_batch_home)
    @driver01 = Rhubarb::BatchDriver.new('einvoice', 'clearCacheJob')
    @control_dir = File.join(@stg_batch_home, 'control')
  end

  it 'should drop a runfile' do
    day_zero = Time.local(2012, 9, 1, 12, 00, 00)

    Timecop.travel(day_zero) do
      expected_runfile_name = @driver.drop_runfile
    end
    latest_runfile = Dir.glob(File.join(@control_dir, '*.run')).sort_by { |runfile| File.mtime(runfile) }.last
    latest_runfile.should be expected_runfile_name
  end
end
