require "spec_helper"

describe RateLimit, :type => :controller do
  let(:mutex) { Mutex.new }
  let(:wait_until) { ConditionVariable.new }

  controller do
    include RateLimit

    def mutex
      @mutex ||= Mutex.new
    end

    def wait_until
      @wait_until ||= ConditionVariable.new
    end

    def current_user
      OpenStruct.new(id: params[:user_id])
    end

    def show
      mutex.synchronize { wait_until.wait(mutex, 1.second) }
      head :ok
    end
  end

  context "a single user" do

    subject do
      threads = Set.new
      thread_count.times do |i|
        threads << Thread.new do
          get :show, :id => i, user_id: 1
        end
      end
      controller.mutex.synchronize { controller.wait_until.broadcast }
      threads.each { |thread| thread.join }
    end

    context "Called too many times at once" do
      let(:thread_count) { 4 }

      it "should raise an error about too many concurrent requests" do
        pending "Threads are hard"

        expect{subject}.to raise_error(RateLimit::RateLimitExceeded)
      end
    end

    context "Called not too many times" do
      let(:thread_count) { 3 }

      it "should raise an error about too many concurrent requests" do
        expect{subject}.to_not raise_error
      end
    end
  end

  context "a variety of users" do

    subject do
      threads = Set.new
      thread_count.times do |i|
        threads << Thread.new do
          get :show, :id => i, user_id: i
        end
      end
      controller.mutex.synchronize { controller.wait_until.broadcast }
      threads.each { |thread| thread.join }
    end

    context "Called too many times at once" do
      let(:thread_count) { 4 }

      it "should raise an error about too many concurrent requests" do(RateLimit::RateLimitExceeded)
      end
    end

    context "Called not too many times" do
      let(:thread_count) { 3 }

      it "should raise an error about too many concurrent requests" do
        expect{subject}.to_not raise_error
      end
    end
  end
end
