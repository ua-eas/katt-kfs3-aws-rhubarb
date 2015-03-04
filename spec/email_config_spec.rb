require_relative 'spec_helper'


describe Rhubarb::Email, "#parse_config" do
  include Helpers



  before(:each) do
    cleanse_live
    allow(Rhubarb).to receive(:batch_home).and_return(@stg_batch_home)

  end

  before(:all) do

    debugger

    add_test_reports

    email_deliverer = Rhubarb::Email.new('ARCHIBUSFOO')

    @js = email_deliverer.get_jobstream
  end

  after(:all) do
    cleanup_email_tracking_files
  end


  it "should generate JobStream representing the whole job_stream, with a correct name" do
    expect(@js.name).to be == "ARCHIBUSFOO"
  end

  it "should generate JobStream representing the whole job_stream, with a correct Output" do
    expect(@js.outputs['job_not_ok']).not_to be_nil
    expect(@js.outputs['job_ok']).not_to be_nil
  end

  it "should generate Output with a correct name" do
    expect(@js.outputs['job_ok'].name).to be == "job_ok"
    expect(@js.outputs['job_not_ok'].name).to be == "job_not_ok"
  end

  it "should generate Output with a correct subject" do
    expect(@js.outputs['job_ok'].subject).to be == "DEV - UAF-FOO-DLV-EMAIL - Job Success"
    expect(@js.outputs['job_not_ok'].subject).to be == "DEV - UAF-FOO-DLV-EMAIL - Job Failed"
  end

  it "should generate Output with a correct message" do

    expected =  "The job FOO has finished successfully.\n"
    expect(@js.outputs['job_ok'].text_part.body.to_s).to be == "The job FOO has finished successfully.\n"

    date = Time.new
    date = date.strftime("%m/%d/%Y")

    expected =  "The job FOO has failed on #{date}, \nattached is a log of events,\n"
    expected += "please see KFS logs for further detail.\n"
    expect(@js.outputs['job_not_ok'].text_part.body.to_s).to be == expected
  end

  it "should generate Output with correct to entries" do
    expect(@js.outputs['job_ok']['to'].to_s).to include("katt-automation@list.arizona.edu")
    expect(@js.outputs['job_ok']['to'].to_s).to include("shaloo@email.arizona.edu")
    expect(@js.outputs['job_ok']['cc'].to_s).to include("rhunter@email.arizona.edu")
    expect(@js.outputs['job_ok']['cc'].to_s).to include("hlo@email.arizona.edu")
    expect(@js.outputs['job_not_ok']['to'].to_s).to include("katt-automation@list.arizona.edu")
    expect(@js.outputs['job_not_ok']['to'].to_s).to include("shaloo@email.arizona.edu")
  end

  it "should generate an Output with correct attachments globs" do
    expect(@js.outputs['job_not_ok'].attachments.map(&:filename)).to include("foo_1.log")
    expect(@js.outputs['job_not_ok'].attachments.map(&:filename)).to include("foo_2.log")
    expect(@js.outputs['job_not_ok'].attachments.map(&:filename)).to include("foo_3.log")
    expect(@js.outputs['job_not_ok'].attachments.map(&:filename)).to include("foo_4.log")
    expect(@js.outputs['job_not_ok'].attachments.map(&:filename)).to include("bar_1.log")
    expect(@js.outputs['job_not_ok'].attachments.map(&:filename)).to include("bar_2.log")
    expect(@js.outputs['job_not_ok'].attachments.map(&:filename)).to include("bar_3.log")
    expect(@js.outputs['job_not_ok'].attachments.map(&:filename)).to include("bar_4.log")

    expect(@js.outputs['job_ok'].attachments.map(&:filename)).to include("foo_1.log")
    expect(@js.outputs['job_ok'].attachments.map(&:filename)).to include("foo_2.log")
    expect(@js.outputs['job_ok'].attachments.map(&:filename)).to include("foo_3.log")
    expect(@js.outputs['job_ok'].attachments.map(&:filename)).to include("foo_4.log")
    expect(@js.outputs['job_ok'].attachments.map(&:filename)).to include("bar_1.log")
    expect(@js.outputs['job_ok'].attachments.map(&:filename)).to include("bar_2.log")
    expect(@js.outputs['job_ok'].attachments.map(&:filename)).to include("bar_3.log")
    expect(@js.outputs['job_ok'].attachments.map(&:filename)).to include("bar_4.log")
    # the helper creates a tracking file for baz_1.log so this should not be included!
    expect(@js.outputs['job_ok'].attachments.map(&:filename)).not_to include("ARCHIBUSFOO_baz_1.log")
    expect(@js.outputs['job_ok'].attachments.map(&:filename)).to include("ARCHIBUSFOO_baz_2.log")
    expect(@js.outputs['job_ok'].attachments.map(&:filename)).to include("ARCHIBUSFOO_baz_3.log")
    expect(@js.outputs['job_ok'].attachments.map(&:filename)).to include("ARCHIBUSFOO_baz_4.log")
  end

  it "should generate multiple Outputs" do
    expect(@js.outputs.count).to be == 2
  end
end
