class FailedWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  def perform(an_argument)
    foo(an_argument)
  end

  def wat_user(too, many, args)
    {id: "wat?"}
  end

  private
  def foo(an_argument)
    raise ExpectedError.new(an_argument)
  end
end
