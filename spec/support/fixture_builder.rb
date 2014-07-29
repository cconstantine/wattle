
FixtureBuilder.configure do |fbuilder|
  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir["spec/factories/*.rb", "spec/support/fixture_builder.rb", "app/models/*.rb"]

  # now declare objects
  fbuilder.factory do
    fbuilder.name :default, Watcher.create!(name: "Fake Watcher", first_name: "Fake", email: "test@example.com")
    inactive_watcher = Watcher.create!(name: "Inactive Fake Watcher", first_name: "Inactive", email: "inactive@example.com")
    inactive_watcher.deactivate!
    fbuilder.name :inactive, inactive_watcher
    fbuilder.name :another_watcher, Watcher.create!(name: "Super Fake Watcher", first_name: "Fakey faker", email: "test2@example.com")

    fbuilder.name(:default, Wat.create_from_exception!(nil, {app_env: 'production'}) {raise RuntimeError.new( "a test")})
    fbuilder.name(:javascript, Wat.create_from_exception!(nil, {app_env: 'production', language: :javascript}) {raise RuntimeError.new( "a test")})
    fbuilder.name(:ruby, Wat.create_from_exception!(nil, {app_env: 'production', language: :ruby}) {raise RuntimeError.new( "a test")})
    fbuilder.name(:with_user_agent, Wat.create_from_exception!(nil, {
        request_headers: {
            HTTP_USER_AGENT: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.110 Safari/537.36"
        },
        app_env: 'production'}
    ) {raise RuntimeError.new( "a test")})

    @grouping1 = 5.times.map do |i|
      Wat.create_from_exception!(nil, {app_name: :app1, app_env: 'production'})  {raise RuntimeError.new( "a test")}
    end.first.groupings.first

    @grouping2 = 5.times.map do |i|
      Wat.create_from_exception!(nil, {app_name: :app2, app_env: 'production'})  {raise RuntimeError.new( "a test")}
    end.first.groupings.first

    @grouping3 = 5.times.map do |i|
      # These two need to be on the same line
      Wat.create_from_exception!(nil, {app_name: :app2, app_env: 'production'})  {raise RuntimeError.new( "a test")}; Wat.create_from_exception!(nil, {app_name: :app2, app_env: 'demo'})  {raise RuntimeError.new( "a test")}
    end.first.groupings.first

    grouping_users = [
        { "user" => {"id" => 1 }, "browser" => nil},
        { "user" => { "id" => 2 }, "browser" => nil},
        { "user" => { "id" => 2 }, "browser" => "FooBrowser"},
        { "user" => { "id" => nil }, "browser" => "FooBrowser"},
        { "user" => { "id" => nil }, "browser" => "Barser"}
    ]

    @grouping4 = grouping_users.map do |grouping_info|
      headers = { "HTTP_USER_AGENT" => grouping_info["browser"] }
      Wat.create_from_exception!(nil, {app_user: grouping_info["user"], request_headers: headers, app_name: :app2, app_env: 'production'})  {raise RuntimeError.new( "a test")}
    end.first.groupings.first

    @normal_javascripts = 5.times.map do |i|
      Wat.create_from_exception!(nil, {app_name: :app2, app_env: 'production', language: :javascript})  {raise RuntimeError.new( "a test")}
    end.first.groupings.first

    @demo_grouping = 5.times.map do |i|
      Wat.create_from_exception!(nil, {app_name: :app1, app_env: 'demo'})  {raise RuntimeError.new( "a test")}
    end.first.groupings.first

    @staging_grouping = 5.times.map do |i|
      Wat.create_from_exception!(nil, {app_name: :app3, app_env: 'staging'})  {raise RuntimeError.new( "a test")}
    end.first.groupings.first


    # Create some wats without groupings
    @resolved = 5.times.map do |i|
      Wat.create_from_exception!(nil, {app_name: :app1, app_env: 'production'})  {raise RuntimeError.new( "a test")}
    end.first.groupings.first

    @resolved.resolve!

    @wontfix = 5.times.map do |i|
      Wat.create_from_exception!(nil, {app_name: :app1, app_env: 'production'})  {raise RuntimeError.new( "a test")}
    end.first.groupings.first
    @wontfix.wontfix!

    @muffled = 5.times.map do |i|
      Wat.create_from_exception!(nil, {app_name: :app1, app_env: 'production'})  {raise RuntimeError.new( "a test")}
    end.first.groupings.first
    @muffled.muffle!
  end
end
