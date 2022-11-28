require "rails_helper"

RSpec.describe "ValidationCodes", type: :request do
  describe "验证码" do
    it "频繁发送会返回 429" do
      post "/api/v1/validation_codes", params: {email: "a492073467@gmail.com"}
      expect(response).to have_http_status 200
      post "/api/v1/validation_codes", params: {email: "a492073467@gmail.com"}
      expect(response).to have_http_status 429
    end
  end
end
