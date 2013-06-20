require 'spec_helper'

describe WatsHelper do
  let(:helper) do
    class A
      include WatsHelper
    end
    A.new
  end

  context "#top_wats" do
    subject {  helper.top_wats }
    it "should select the top three wats" do
      subject.count.should == 3
    end
  end

  context "#app_envs" do
    before do
      Wat.create_from_exception!(nil, {app_env: 'hawaii'})  {raise RuntimeError.new( "a test")}
    end
    subject { helper.app_envs }
    it { should =~ ['production', 'hawaii'] }
  end

end