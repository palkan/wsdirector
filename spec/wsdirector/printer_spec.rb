require "spec_helper"

describe WSdirector::Printer do
  subject { WSdirector::Printer }
  it 'print message as expected' do
    expect(subject).to receive_message_chain(:puts, :colorize).with('test').with(:green)
    subject.out('test', :green)
  end

  it 'print nothing when it tests' do
    allow(WSdirector::Configuration).to receive(:test?).and_return(true)
    expect(subject).to_not receive(:puts)
    subject.out('test', :green)
  end
end
