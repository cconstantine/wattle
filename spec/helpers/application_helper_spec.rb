require 'spec_helper'

describe ApplicationHelper do
  let(:helper) do
    class A
      include ApplicationHelper
    end
    A.new
  end

  context "#checked?" do
    let(:param) { :fun_param }
    let(:key) { "fun_key" }
    let(:params) { { fun_param: ["fun_key", "terrible_key"] }  }

    before { stub(helper).params { params } }

    subject {  helper.checked?(param, key) }
    it { should == true }

    context "when the key isn't in the params" do
      let(:params) { { fun_param: ["terrible_key"]} }
      it { should == false}
    end

    context "when the param doesn't exist" do
      let (:params) { { space_dogs: ["love_space_cats"] } }
      it { should == false}
    end
  end
end