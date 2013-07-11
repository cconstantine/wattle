class WatMailer < ActionMailer::Base
  default :from => "wattle@example.com"
  layout "mailer"

  def create(wat)
    @wat = wat

    @no_backtrace = true
    mail :to => Watcher.pluck(:email), :subject => "[#{@wat.app_name}##{@wat.app_env[0..3]}] #{@wat.message}"
  end
end