require_relative 'spec_helper'

describe Rhubarb::Logger, '.new' do
  include Helpers

  before(:all) do
    cleanse_live
  end

  it 'should abandon ship without $BATCH_HOME' do
    allow(Rhubarb).to receive(:batch_home).and_return(nil)
    expect { Rhubarb::Logger.new('foo') }.to raise_error(Rhubarb::MissingBatchHomeError)
  end

  it 'should abandon ship with an invalid $BATCH_HOME' do
    batch_home = File.join(@live_dir, 'uaf-fake')
    allow(Rhubarb).to receive(:batch_home).and_return(batch_home)
    expect { Rhubarb::Logger.new('foo') }.to raise_error(Rhubarb::InvalidBatchHomeError)
  end

  it 'should abandon ship with an empty $BATCH_HOME directory' do
    batch_home = File.join(@live_dir, 'uaf-tst')
    allow(Rhubarb).to receive(:batch_home).and_return(batch_home)
    expect { Rhubarb::Logger.new('foo') }.to raise_error(Rhubarb::EmptyBatchHomeError)
  end

  it 'should abandon ship with empty arguments' do
    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    expect { Rhubarb::Logger.new }.to raise_error(ArgumentError)
  end

  it 'should initialize successfully with one valid argument' do
    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    expect { Rhubarb::Logger.new('foo') }.to_not raise_error
  end
end

describe Rhubarb::Logger, '#log' do
  include Helpers

  before(:each) do
    cleanse_live

    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    @logger = Rhubarb::Logger.new('bar')
  end

  it 'should log INFO successfully' do
    #log4r_logger = double('log4r_logger')
    #@logger.stub(:log4r_logger) { log4r_logger }
    expect(@logger.log4r_logger).to receive(:info).with('message')
    @logger.info 'message'
  end
end

describe Rhubarb::Logger, '#h1, #h2, #h3' do
  include Helpers

  before(:each) do
    cleanse_live

    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    @logger = Rhubarb::Logger.new('bar')
    @message01 = 'Meh Big Fancy Header'
  end

  it "should log H1's successfully" do
    message = 'Big Fancy Header'
    expect(@logger.log4r_logger).to receive(:info).with("# #{message}")
    @logger.h1(message)
  end

  it "should log H2's successfully" do
    message = 'Biggish Fancy Header'
    expect(@logger.log4r_logger).to receive(:info).with("## #{message}")
    @logger.h2(message)
  end

  it "should log H3's successfully" do
    expect(@logger.log4r_logger).to receive(:info).with("### #{@message01}")
    @logger.h3(@message01)
  end

  it "should log H4's successfully" do
    expect(@logger.log4r_logger).to receive(:info).with("#### #{@message01}")
    @logger.h4(@message01)
  end

  it "should log H5's successfully" do
    expect(@logger.log4r_logger).to receive(:info).with("##### #{@message01}")
    @logger.h5(@message01)
  end
end

describe Rhubarb::Logger, '#log4r_logger' do
  include Helpers

  before(:each) do
    cleanse_live

    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    @logger = Rhubarb::Logger.new('foo')
    @message01 = 'texty text text'
  end

  it "should actually log successfully" do
    @logger.info(@message01)
    lines = File.readlines(@logger.job_stream_file)
    expect(lines.last).to match /[0-9:]{8} \(INFO\) #{@message01}/
  end

  it "should actually log successfully" do
    @logger.warn(@message01)
    lines = File.readlines(@logger.job_stream_file)
    expect(lines.last).to match /[0-9:]{8} \(WARN\) #{@message01}/
  end

  it "should actually log successfully" do
    @logger.error(@message01)
    lines = File.readlines(@logger.job_stream_file)
    expect(lines.last).to match /[0-9:]{8} \(ERROR\) #{@message01}/
  end
end

describe Rhubarb::Logger, '#stamp' do
  include Helpers

  before(:each) do
    cleanse_live

    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    @logger = Rhubarb::Logger.new('foo')
    @message01 = 'texty text text'
  end

  it "should stamp successfully" do
    expect(@logger.log4r_logger).to receive(:info).with(@message01)
    @logger.stamp(@message01)
  end

  it "should actually stamp successfully" do
    @logger.stamp(@message01)
    lines = File.readlines(@logger.job_stream_file)
    expect(lines.last).to match /\w+, \d+ \w+ \d{4} [0-9:]{8} [\-0-9]+ #{@message01}/
  end
end
