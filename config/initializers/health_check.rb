HealthCheck.setup do |config|

  config.standard_checks = [ 'site', 'database', 'migration', 'cache' ]

end