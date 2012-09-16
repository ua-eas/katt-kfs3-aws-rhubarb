require_relative 'spec_helper'

describe Rhubarb::BatchLogRoller, '.new' do
  include Helpers

  before(:all) do
    cleanse_live
  end

  it 'should abandon ship without $BATCH_HOME' do
    Rhubarb::BatchLogRoller.stub(:batch_home).and_return(nil)
    expect { Rhubarb::BatchLogRoller.new }.to raise_error(Rhubarb::MissingBatchHomeError)
  end

  it 'should abandon ship with an invalid $BATCH_HOME' do
    batch_home = File.join(@live_dir, 'uaf-fake')
    Rhubarb::BatchLogRoller.stub(:batch_home).and_return(batch_home)
    expect { Rhubarb::BatchLogRoller.new }.to raise_error(Rhubarb::InvalidBatchHomeError)
  end

  it 'should abandon ship with an empty $BATCH_HOME directory' do
    batch_home = File.join(@live_dir, 'uaf-tst')
    Rhubarb::BatchLogRoller.stub(:batch_home).and_return(batch_home)
    expect { Rhubarb::BatchLogRoller.new }.to raise_error(Rhubarb::EmptyBatchHomeError)
  end

  it 'should initialize successfully' do
    Rhubarb::BatchLogRoller.stub(:batch_home).and_return(@stg_batch_home)
    expect { Rhubarb::BatchLogRoller.new }.to_not raise_error
  end
end

describe Rhubarb::BatchLogRoller, '#roll' do
  include Helpers

  before(:each) do
    cleanse_live

    Rhubarb::BatchLogger.stub(:batch_home).and_return(@stg_batch_home)
    @logger01 = Rhubarb::BatchLogger.new('foo')
    @logger02 = Rhubarb::BatchLogger.new('bar')
    @message01 = 'Ridiculously Interesting Message'

    Rhubarb::BatchLogRoller.stub(:batch_home).and_return(@stg_batch_home)
    @roller = Rhubarb::BatchLogRoller.new
  end

  it 'should not blow up if there is nothing to roll' do
    expect { @roller.roll }.to_not raise_error
  end

  context 'after log files has been written to' do
    before(:each) do
      @logger01.info @message01
      @logger02.info @message01

      @roller.roll
    end

    it 'should roll log files out of the way' do
      Dir.glob(File.join(@stg_batch_home, 'logs', '*.log')).should be_empty
    end

    it 'should roll log files into their archive location' do
      File.directory?(File.join(@stg_batch_home, 'logs', 'foo')).should be_true
      File.directory?(File.join(@stg_batch_home, 'logs', 'bar')).should be_true
    end
  end
end
