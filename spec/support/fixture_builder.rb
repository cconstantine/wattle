
FixtureBuilder.configure do |fbuilder|
  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir["spec/factories/*.rb", "spec/support/fixture_builder.rb", "app/models/*.rb"]

  # now declare objects
  fbuilder.factory do
    fbuilder.name :default, Watcher.create!(name: "Fake Watcher", first_name: "Fake", email: "test@example.com")
    fbuilder.name :another_watcher, Watcher.create!(name: "Super Fake Watcher", first_name: "Fakey faker", email: "test2@example.com")

    fbuilder.name(:default, Wat.create_from_exception! {raise RuntimeError.new( "a test")})


    @grouping1 = 5.times.map do |i|
      Wat.create_from_exception! {raise RuntimeError.new( "a test")}
    end.first.groupings.first

    @grouping2 = 5.times.map do |i|
      Wat.create_from_exception! {raise RuntimeError.new( "a test")}
    end.first.groupings.first

    #
    #@grouping1.wats = [wats[0], wats[1], wats[2], wats[8], wats[9]]
    #@grouping1.key_line = wats[0].key_line
    #@grouping1.error_class = wats[15].error_class
    #@grouping1.save!
    #
    #@grouping2.wats = [wats[3], wats[4], wats[5], wats[6], wats[7]]
    #@grouping2.key_line = wats[15].key_line
    #@grouping2.error_class = wats[15].error_class
    #@grouping2.save!

    # Create some wats without groupings
    @resolved = 5.times.map do |i|
      Wat.create_from_exception! {raise RuntimeError.new( "a test")}
    end.first.groupings.first

    #@resolved.wats = [wats[10], wats[11], wats[12], wats[13], wats[14]]
    #@resolved.key_line = wats[15].key_line
    #@resolved.error_class = wats[15].error_class
    @resolved.resolve!

    # Create some wats without groupings
    @acknowledged = 5.times.map do |i|
      Wat.create_from_exception! {raise RuntimeError.new( "a test")}
    end.first.groupings.first
    #@acknowledged.wats = [wats[15], wats[16], wats[17], wats[18], wats[19]]
    #@acknowledged.key_line = wats[15].key_line
    #@acknowledged.error_class = wats[15].error_class
    @acknowledged.acknowledge!
  end
end
