require 'digest/sha1'

class GroupingMailer < ActionMailer::Base
  default :from => Proc.new { "Wattle <#{ENV['MAILER_FROM'] || Secret.mailer[:from]}>" }
  layout "mailer"

  def notify_about_wat(watcher, grouping)
    @grouping = grouping
    @wat = grouping.wats.last
    @new_count = grouping.new_wats.count

    @app_envs = @grouping.new_wats.pluck(:app_env).uniq
    short_app_envs_list = @app_envs.map { |x| "##{x[0..3]}" }.join(" ")
    mail to: watcher.email,
         subject: "[#{@wat.app_name} #{short_app_envs_list}] Grouping #{@grouping.id}"
  end

  def notify_about_note(watcher, grouping)
    @grouping = grouping
    @wat = grouping.wats.last
    @new_count = grouping.new_wats.count

    @app_envs = @grouping.new_wats.pluck(:app_env).uniq
    short_app_envs_list = @app_envs.map { |x| "##{x[0..3]}" }.join(" ")
    mail to: watcher.email,
         subject: "A new note was added to [#{@wat.app_name} #{short_app_envs_list}] Grouping #{@grouping.id}"
  end
end
