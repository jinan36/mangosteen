require "rails_helper"

RSpec.describe "ValidationCodes", type: :request do
  describe "会话" do
    it "登录" do
      User.create email: "a492073467@gmail.com"
      post "/api/v1/session", params: {email: "a492073467@gmail.com", code: "123456"}
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["jwt"]).to be_a(String)
    end
    it "未注册" do
      post "/api/v1/session", params: {email: "a492073467@gmail.com", code: "123456"}
      expect(response).to have_http_status 404
    end
  end
end
