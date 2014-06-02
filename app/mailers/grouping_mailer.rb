require 'digest/sha1'

class GroupingMailer < ActionMailer::Base
  default :from => Proc.new { ENV['MAILER_FROM'] || Secret.mailer[:from] }
  layout "mailer"

  def notify(grouping)
    @grouping = grouping
    @wat = grouping.wats.last
    @new_count = grouping.new_wats.count

    @app_envs = @grouping.new_wats.pluck(:app_env).uniq
    mail :bcc => Watcher.pluck(:email), :subject => "[#{@wat.app_name} #{@app_envs.map {|x| "##{x[0..3]}"}.join(" ")}] Grouping #{@grouping.id}"
  end
end
