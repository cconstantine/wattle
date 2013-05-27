class WatMailer < ActionMailer::Base
  default :from => "from@example.com"
  layout "mailer"

  def create(wat)
    @wat = wat

    @no_backtrace = true
    mail :to => Watcher.pluck(:email), :subject => "A wild wat appears"
  end
end