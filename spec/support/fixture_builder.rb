FixtureBuilder.configure do |fbuilder|
  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir["spec/factories/*.rb", "spec/support/fixture_builder.rb", "app/models/*.rb"]

  # now declare objects
  fbuilder.factory do

    #e = err {raise RuntimeError.new( "a test")}
    #fbuilder.name(:default, Wat.create!(message: e.message, error_class: e.class.to_s, backtrace: e.backtrace))
    #
    #10.times do |i|
    #  e = err {raise RuntimeError.new( "#{i} test")}
    #  fbuilder.name(:"wat_#{i}", Wat.create!(message: e.message, error_class: e.class.to_s, backtrace: e.backtrace))
    #end
  end
end