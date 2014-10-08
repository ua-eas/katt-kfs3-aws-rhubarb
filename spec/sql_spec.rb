require_relative 'spec_helper'

describe Rhubarb::SQL, '.new' do
  include Helpers

  before(:all) do
    cleanse_live
  end

  it 'should abandon ship without $BATCH_HOME' do
    allow(Rhubarb).to receive(:batch_home).and_return(nil)
    expect { Rhubarb::SQL.new('foo.sql') }.to raise_error(Rhubarb::MissingBatchHomeError)
  end

  it 'should abandon ship with an invalid $BATCH_HOME' do
    batch_home = File.join(@live_dir, 'uaf-fake')
    allow(Rhubarb).to receive(:batch_home).and_return(batch_home)
    expect { Rhubarb::SQL.new('foo.sql') }.to raise_error(Rhubarb::InvalidBatchHomeError)
  end

  it 'should abandon ship with an empty $BATCH_HOME directory' do
    batch_home = File.join(@live_dir, 'uaf-tst')
    allow(Rhubarb).to receive(:batch_home).and_return(batch_home)
    expect { Rhubarb::SQL.new('foo.sql') }.to raise_error(Rhubarb::EmptyBatchHomeError)
  end

  it 'should abandon ship without a sql directory' do
    batch_home = File.join(@live_dir, 'uaf-cfg')
    allow(Rhubarb).to receive(:batch_home).and_return(batch_home)
    expect { Rhubarb::SQL.new('foo.sql') }.to raise_error(Rhubarb::SQL::MissingSQLDirectoryError)
  end

  it 'should initialize successfully' do
    pending
    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)
    allow(Rhubarb::SQL).to receive(:sql_home).and_return()
    expect { Rhubarb::SQL.new('foo.sql') }.to_not raise_error
  end
end
