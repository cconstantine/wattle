class WatCatcher
  def initialize(app)
    @app = app
  end

  def call(env)
    p ['hi', 'there']
    status, headers, response = @app.call(env)

    [status, headers, response]
  rescue
    request = ::Rack::Request.new(env)
    params = request.params
    session = request.session.as_json

    # Build the clean url (hide the port if it is obvious)
    url = "#{request.scheme}://#{request.host}"
    url << ":#{request.port}" unless [80, 443].include?(request.port)
    url << request.fullpath

    Wat.create_from_exception!($!, request_params: params, session: session, )
    raise
  end
end