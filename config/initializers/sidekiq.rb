schedule_file = "#{Rails.root}/config/sidekiq_schedule.yml"

if WatConfig.secret_value('SYSTEM_ACCOUNT_APPS').present? && File.exists?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load(ERB.new(File.read(schedule_file)).result)
end
