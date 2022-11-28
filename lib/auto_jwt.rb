class AutoJwt
  def initialize(app)
    @app = app
  end

  def call(env)
    header = env["HTTP_AUTHORIZATION"]
    token = begin
      header.split(" ")[1]
    rescue
      ""
    end
    payload = begin
      JWT.decode token, Rails.application.credentials.hmac_secret, true, {algorithm: "HS256"}
    rescue
      nil
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
