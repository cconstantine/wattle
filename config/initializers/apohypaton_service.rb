service_name = ENV['APOHYPATON_SERVICE_NAME'] || ENV['UPSTART_JOB']

if service_name
  services = Apohypaton::Service.load_from_yaml_file(File.expand_path('../../apohypaton.yml', __FILE__))

  matching_service = services.select { |s| s.name == service_name }.first

  # Don't bother registering if the service definition DNE
  if matching_service
    matching_service.save!
  end
end
