require 'spec_helper'

describe "ActiveRecord::Base.with_timeout" do
  let(:timeout_time) {"1" }

  subject { ActiveRecord::Base.with_timeout(timeout_time) { ActiveRecord::Base.connection.execute("select pg_sleep(#{query_time})")} }

  context "with a too-long query" do
    let(:query_time) { "10" }
    it "raises a timeout" do
     expect { subject }.to raise_error(ActiveRecord::QueryTimeout)
    end
  end

  context "with a quick query" do
    let(:query_time) { "0" }
    it "raises a timeout" do
     expect { subject }.to_not raise_error
    end
  end

  context "with an invalid statement" do
    let(:query_time) { "laksdf)"}

    it "tells us about the invalid statement" do
      expect { subject }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  context "with nested timeouts" do
    subject do
      ActiveRecord::Base.with_timeout(2.seconds) do

        ActiveRecord::Base.connection.execute("select pg_sleep(1.1)")

        ActiveRecord::Base.with_timeout(1.seconds) { ActiveRecord::Base.connection.execute("select 1") }

        ActiveRecord::Base.connection.execute("select pg_sleep(1.1)")
      end
    end

    it "works" do
      expect { subject }.to_not raise_error
    end
  end
end
