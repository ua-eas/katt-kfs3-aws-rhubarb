require_relative 'spec_helper'

describe Rhubarb::NetKernel, '.new' do
  include Helpers

  before(:all) do
    cleanse_live
    @netkernel = Rhubarb::NetKernel.new('http://uaz-so-w02.mosaic.arizona.edu:8080/kfsjpmccardholder','username','password')
  end

  it 'should initialize successfully' do
    expect(@netkernel.parsed_uri.to_s).to eq('http://uaz-so-w02.mosaic.arizona.edu:8080/kfsjpmccardholder')
  end

end

describe Rhubarb::NetKernel, '#succeeded?' do
  include Helpers

  before(:each) do
    cleanse_live

    @netkernel = Rhubarb::NetKernel.new('http://uaz-so-w02.mosaic.arizona.edu:8080/kfsjpmccardholder','username','password')
  end

  it 'should return true if #notify returns "a.txt: a.xml"' do
    expect(@netkernel.succeeded? "a.txt: a.xml").to be true
  end

  it 'should return false if #notify returns "anything else here"' do
    expect(@netkernel.succeeded? "a.txt: 404").to be false
  end

  it 'should return false if #notify returns an error on a single line' do
    expect(@netkernel.succeeded? "b.txt: b.xml\na.txt: 404").to be false
  end

  it 'should return true if #notify returns no errors' do
    expect(@netkernel.succeeded? "b.txt: b.xml\na.txt: a.xml").to be true
  end

  it 'should return true if #notify returns nothing at all' do
    expect(@netkernel.succeeded? "").to be true
  end
end

describe Rhubarb::NetKernel, '#notify?' do
  include Helpers

  before(:each) do
    cleanse_live

    @netkernel = Rhubarb::NetKernel.new('http://google.com','username','password')
  end

  it 'should return a string' do
    expect(@netkernel.notify).to be_a String
  end

  it 'should have a nonzero length' do
    expect(@netkernel.notify.length).to be > 0
  end

end
