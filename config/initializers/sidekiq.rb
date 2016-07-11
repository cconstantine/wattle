schedule_file = "#{Rails.root}/config/sidekiq_schedule.yml"

if File.exists?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load(ERB.new(File.read(schedule_file)).result)
end
