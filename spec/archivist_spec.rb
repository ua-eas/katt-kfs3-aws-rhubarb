require_relative 'spec_helper'

describe Rhubarb::Archivist, '.new' do
  include Helpers

  before(:all) do
    cleanse_live
  end

  it 'should abandon ship without $BATCH_HOME' do
    Rhubarb.stub(:batch_home).and_return(nil)
    expect { Rhubarb::Archivist.new('foo') }.to raise_error(Rhubarb::MissingBatchHomeError)
  end

  it 'should abandon ship with an invalid $BATCH_HOME' do
    batch_home = File.join(@live_dir, 'uaf-fake')
    Rhubarb.stub(:batch_home).and_return(batch_home)
    expect { Rhubarb::Archivist.new('foo') }.to raise_error(Rhubarb::InvalidBatchHomeError)
  end

  it 'should abandon ship with an empty $BATCH_HOME directory' do
    batch_home = File.join(@live_dir, 'uaf-tst')
    Rhubarb.stub(:batch_home).and_return(batch_home)
    expect { Rhubarb::Archivist.new('foo') }.to raise_error(Rhubarb::EmptyBatchHomeError)
  end

  it 'should abandon ship with empty arguments' do
    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    expect { Rhubarb::Archivist.new }.to raise_error(ArgumentError)
  end

  it 'should initialize successfully with one valid argument' do
    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    expect { Rhubarb::Archivist.new('foo') }.to_not raise_error
  end
end

describe Rhubarb::Archivist, '#archive' do
  include Helpers

  before(:each) do
    cleanse_live

    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    @accept_dir   = ['purap', 'electronicInvoice', 'accept']
    @shipping_dir = ['pdp', 'shipping']
    @pcard_dir    = ['fp', 'procurementCard']
    @archivist_01 = Rhubarb::Archivist.new(@accept_dir.join('/'))
    @archivist_02 = Rhubarb::Archivist.new(@shipping_dir.join('/'))
    @archivist_03 = Rhubarb::Archivist.new(@pcard_dir.join('/'))
    @staging_dir  = File.join(@stg_batch_home, 'staging')
    @archive_dir  = File.join(@stg_batch_home, 'archive')
  end

  it 'should log an archive job successfully' do
    @archivist_01.logger.should_receive(:info).at_least(3).times
    @archivist_01.archive!
  end

  it 'should remove from staging/ successfully' do
    @archivist_01.archive!
    Dir.glob(File.join(@staging_dir, *@accept_dir) + '/*').should be_empty
  end

  it 'should add to archive/ successfully' do
    @archivist_01.archive!
    Dir.glob(File.join(@archive_dir, *@accept_dir) + '/*').should_not be_empty
  end

  it 'should archive successfully even if the target directory doesn\'t exist' do
    @archivist_02.archive!
    #@archivist_02.logger.should_receive(:info).at_least(4).times
    Dir.glob(File.join(@staging_dir, *@shipping_dir) + '/*').should be_empty
    Dir.glob(File.join(@archive_dir, *@shipping_dir) + '/*').should_not be_empty
  end

  it 'should not raise when source directory doesn\'t exist' do
    expect { @archivist_03.archive! }.to_not raise_error
  end
end

