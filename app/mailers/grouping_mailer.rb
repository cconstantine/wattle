require 'digest/sha1'

class GroupingMailer < ActionMailer::Base
  default :from => Proc.new { "Wattle <#{ENV['MAILER_FROM'] || Secret.mailer[:from]}>" }
  layout "mailer"

  def notify(watcher, grouping)
    @grouping = grouping
    @wat = grouping.wats.last
    @new_count = grouping.new_wats.count

    @new_users_count = grouping.new_wats.distinct('app_user -> \'id\'').count
    @users_count = grouping.app_user_count

    @app_envs = @grouping.new_wats.pluck(:app_env).uniq
    mail :to => watcher.email, :subject => "[#{@wat.app_name} #{@app_envs.map {|x| "##{x[0..3]}"}.join(" ")}] Grouping #{@grouping.id}"
  end
end
