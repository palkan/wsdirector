require "spec_helper"

describe WSdirector::Printer do
  subject { WSdirector::Printer }
  it 'print message as expected' do
    allow(WSdirector::Configuration).to receive(:test?).and_return(false)
    expect_any_instance_of(String).to receive(:colorize).with(:green).and_return('test')
    expect(subject).to receive(:puts).with('test')
    subject.out('test', :green)
  end

  it 'print nothing when it tests' do
    allow(WSdirector::Configuration).to receive(:test?).and_return(true)
    expect(subject).to_not receive(:puts)
    subject.out('test', :green)
  end
end
