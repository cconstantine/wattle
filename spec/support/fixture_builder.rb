

def capture_error &block
  err = nil
  begin
    yield block
  rescue
    err = $!
  end
  return err
end
FixtureBuilder.configure do |fbuilder|
  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir["spec/factories/*.rb", "spec/support/fixture_builder.rb", "app/models/*.rb"]

  # now declare objects
  fbuilder.factory do


    e = capture_error {raise RuntimeError.new( "a test")}
    fbuilder.name(:default, Wat.create!(message: e.message, error_class: e.class.to_s, backtrace: e.backtrace))

  end
end