require 'digest/sha1'

class StreamEventMailer < ActionMailer::Base
  add_template_helper(WatchersHelper)

  default :from => Proc.new { "Wattle <#{ENV['MAILER_FROM'] || Secret.mailer[:from]}>" }
  layout "mailer"

  def notify(watcher, stream_event)
    @grouping = stream_event.grouping
    @stream_event = stream_event
    @event = stream_event.context

    @app_envs = @grouping.app_envs
    @app_name = @grouping.app_names.first
    mail :to => watcher.email, :subject => "[#{@app_name} #{@app_envs.map {|x| "##{x[0..3]}"}.join(" ")}] Grouping #{@grouping.id}"
  end
end
