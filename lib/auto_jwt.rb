class AutoJwt
  def initialize(app)
    @app = app
  end

  def call(env)
    # jwt 白名单
    return @app.call(env) if ["/api/v1/validation_codes", "/api/v1/session"].include? env["PATH_INFO"]

    header = env["HTTP_AUTHORIZATION"]
    token = begin
      header.split(" ")[1]
    rescue
      ""
    end
    payload = begin
      JWT.decode token, Rails.application.credentials.hmac_secret, true, {algorithm: "HS256"}
    rescue JWT::ExpiredSignature
      return [401, {}, [JSON.generate({reason: "token expired"})]]
    rescue
      return [401, {}, [JSON.generate({reason: "token invalid"})]]
    end
    env["current_user_id"] = begin
      payload[0]["user_id"]
    rescue
      nil
    end
    @status, @headers, @response = @app.call(env)
    [@status, @headers, @response]
  end
end
