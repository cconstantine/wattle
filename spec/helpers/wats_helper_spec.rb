require 'spec_helper'

describe WatsHelper do
  let(:helper) do
    class A
      include WatsHelper
    end
    A.new
  end

  context "#app_envs" do
    before do
      Wat.create_from_exception!(nil, {app_env: 'hawaii'})  {raise RuntimeError.new( "a test")}
    end
    subject { helper.app_envs }
    it { is_expected.to match_array ['demo', 'production', 'staging', 'hawaii'] }
  end

end
