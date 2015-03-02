class FailedWorker
  include Sidekiq::Worker

  def perform
    foo
  end


  private
  def foo
    raise ExpectedError.new("Job")
  end
end