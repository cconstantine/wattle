require 'spec_helper'

describe ApplicationHelper do
  let(:helper) do
    class A
      include ApplicationHelper
    end
    A.new
  end



  describe '#wats' do
    let(:group) { groupings(:grouping3) }
    let(:filters) { { app_env: 'demo' } }

    before { allow(helper).to receive(:filters) { filters } }

    it 'returns filtered wats for a given group' do
      expect(helper.wats(group)).to have(5).items
      expect(helper.wats(group).pluck(:app_env).uniq).to eq ['demo']
    end
  end
end
