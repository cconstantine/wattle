service_name = ENV['APOHYPATON_SERVICE_NAME'] || ENV['UPSTART_JOB']

services = Apohypaton::Service.load_from_yaml_file(File.expand_path('../../apohypaton.yml', __FILE__))

matching_service = services.select { |s| s.name == service_name }.first

if service_name
  matching_service.save!
end
