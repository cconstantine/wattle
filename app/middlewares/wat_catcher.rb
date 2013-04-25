class WatCatcher
  def initialize(app)
    @app = app
    @client = HTTPClient.new
    @backgrounder = Backgrounder.new
  end

  def call(env)
    @app.call(env)
  rescue
    excpt = $!
    @backgrounder.queue do
      request = ::Rack::Request.new(env)
      params = request.params
      session = request.session.as_json
      page_url = request.url

      # Build the clean url (hide the port if it is obvious)
      url = "#{request.scheme}://#{request.host}"
      url << ":#{request.port}" unless [80, 443].include?(request.port)
      url << request.fullpath

      @client.post("http://localhost:3000/wats",
                     "wat[page_url]" => page_url,
                     "wat[request_params]" => params,
                     "wat[session]" => session,
                     "wat[backtrace][]" => excpt.backtrace.to_a,
                     "wat[message]" => excpt.message,
                     "wat[error_class]" => excpt.class.to_s
                  )
    end
    raise
  end
end