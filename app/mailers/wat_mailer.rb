class WatMailer < ActionMailer::Base
  default :from => "wattle@example.com"
  layout "mailer"

  def create(wat)
    @wat = wat

    @no_backtrace = true
    mail :to => Watcher.pluck(:email), :subject => "[#{@wat.app_env.upcase}] #{@wat.message}"
  end
end