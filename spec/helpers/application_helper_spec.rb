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

    before { stub(helper).filters { filters } }

    it 'returns filtered wats for a given group' do
      helper.wats(group).count.should == 5
      helper.wats(group).pluck(:app_env).uniq.should == ['demo']
    end
  end
end
