class WatCatcher
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue
    request = ::Rack::Request.new(env)
    params = request.params
    session = request.session.as_json
    page_url = request.url

    # Build the clean url (hide the port if it is obvious)
    url = "#{request.scheme}://#{request.host}"
    url << ":#{request.port}" unless [80, 443].include?(request.port)
    url << request.fullpath

    Wat.create_from_exception!($!, page_url: page_url, request_params: params, session: session, )
    raise
  end
end