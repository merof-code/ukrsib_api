module UkrsibAPI
  class RequestIDMiddleware < Faraday::Middleware
    def call(env)
      env.request_headers["X-Request-ID"] = SecureRandom.uuid
      @app.call(env)
    end
  end
end
