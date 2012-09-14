require_relative 'spec_helper'

describe Rhubarb::BatchLogger, '.new' do
  before(:all) do
    @live_dir       = File.join(File.dirname(__FILE__), 'live')
    @canon_dir      = File.join(File.dirname(__FILE__), 'canon')
    @live_files     = File.join(@live_dir, '*')
    @canon_files    = File.join(@canon_dir, '*')
    @stg_batch_home = File.join(@live_dir, 'uaf-stg')

    # Delete everything in 'live'
    FileUtils.rm_rf Dir.glob(@live_files)

    # Copy from 'canon' to 'live'
    FileUtils.cp_r Dir.glob(@canon_files), @live_dir
  end

  it 'should abandon ship without $BATCH_HOME' do
    Rhubarb::BatchLogger.stub(:batch_home).and_return(nil)
    #Rhubarb::BatchLogger.class_eval { def batch_home; nil; end } # stub it
    expect { Rhubarb::BatchLogger.new('FOO') }.to raise_error(Rhubarb::MissingBatchHomeError)
  end

  it 'should abandon ship with an invalid $BATCH_HOME' do
    batch_home = File.join(@live_dir, 'uaf-fake')
    Rhubarb::BatchLogger.stub(:batch_home).and_return(batch_home)
    #Rhubarb::BatchLogger.class_eval { def batch_home; batch_home; end } # stub it
    expect { Rhubarb::BatchLogger.new('FOO') }.to raise_error(Rhubarb::InvalidBatchHomeError)
  end

  it 'should abandon ship with an empty $BATCH_HOME directory' do
    batch_home = File.join(@live_dir, 'uaf-tst')
    Rhubarb::BatchLogger.stub(:batch_home).and_return(batch_home)
    expect { Rhubarb::BatchLogger.new('FOO') }.to raise_error(Rhubarb::EmptyBatchHomeError)
  end

  it 'should abandon ship with empty arguments' do
    Rhubarb::BatchLogger.stub(:batch_home).and_return(@stg_batch_home)
    expect { Rhubarb::BatchLogger.new }.to raise_error(ArgumentError)
  end

  it 'should initialize successfully with one valid argument' do
    Rhubarb::BatchLogger.stub(:batch_home).and_return(@stg_batch_home)
    expect { Rhubarb::BatchLogger.new('FOO') }.to_not raise_error
  end
end

describe Rhubarb::BatchLogger, '#log' do
  before(:all) do
    @live_dir       = File.join(File.dirname(__FILE__), 'live')
    @stg_batch_home = File.join(@live_dir, 'uaf-stg')
    Rhubarb::BatchLogger.stub(:batch_home).and_return(@stg_batch_home)
    @logger = Rhubarb::BatchLogger.new('BAR')
  end

  it 'should log INFO successfully' do
    #log4r_logger = double('log4r_logger')
    #@logger.stub(:log4r_logger) { log4r_logger }
    @logger.log4r_logger.should_receive(:info).with('message')
    @logger.info 'message'
  end
end

describe Rhubarb::BatchLogger, '#h1' do
  before(:all) do
    @live_dir       = File.join(File.dirname(__FILE__), 'live')
    @stg_batch_home = File.join(@live_dir, 'uaf-stg')
    Rhubarb::BatchLogger.stub(:batch_home).and_return(@stg_batch_home)
    @logger = Rhubarb::BatchLogger.new('BAR')
  end

  it "should log H1's successfully" do
    message = 'Big Fancy Header'
    @logger.log4r_logger.should_receive(:info).with("# #{message}")
    @logger.h1(message)
  end

  it "should log H2's successfully" do
    message = 'Biggish Fancy Header'
    @logger.log4r_logger.should_receive(:info).with("## #{message}")
    @logger.h2(message)
  end

  it "should log H3's successfully" do
    message = 'Meh Big Fancy Header'
    @logger.log4r_logger.should_receive(:info).with("### #{message}")
    @logger.h3(message)
  end
end
