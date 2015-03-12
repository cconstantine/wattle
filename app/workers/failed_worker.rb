class FailedWorker
  include Sidekiq::Worker

  def perform(an_argument)
    foo(an_argument)
  end


  private
  def foo(an_argument)
    raise ExpectedError.new(an_argument)
  end
end
