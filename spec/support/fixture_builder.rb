

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



    @grouping1 = Grouping.create!
    @grouping2 = Grouping.create!

    # Create some wats without groupings
    wats = 10.times.map do |i|
      wat = Wat.create_from_exception! {raise RuntimeError.new( "a test")}
      wat.groupings.each do|x| x.destroy end
      wat.groupings.destroy_all
      wat
    end


    @grouping1.wats = [wats[0], wats[1], wats[2], wats[8], wats[9]]
    @grouping1.save!

    @grouping2.wats = [wats[3], wats[4], wats[5], wats[6], wats[7]]
    @grouping2.save!
  end
end