require "spec_helper"

describe WSdirector::ResultsHolder do
  let(:results_holder) { WSdirector::ResultsHolder.new }

  it 'has groups hash' do
    expect(results_holder.groups).to eq({})
  end

  describe '#<<' do
    it 'add result instance to appropriate group' do
      result = instance_double(WSdirector::Result)
      allow(result).to receive(:group).and_return('default')
      results_holder << result
      expect(results_holder.groups['default'].last).to eq(result)
    end
  end

  describe '#print_result' do
    context 'when there is no fails' do
      before(:example) do
        allow(results_holder).to receive(:groups) do
          {
            'default' => [
                instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 }),
                instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 }),
                instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 }),
                instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 }),
                instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 })
              ]
          }
        end
      end
       it 'print success message for every group' do
         expect(results_holder).to receive(:p).with('Group default - all messages success')
         results_holder.print_result
       end
    end

    context 'when there is fails' do
      it 'print fail message'
      it 'print fail group'
      it 'print specific errors'
    end
  end
end
