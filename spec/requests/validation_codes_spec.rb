require "rails_helper"

RSpec.describe "ValidationCodes", type: :request do
  describe "验证码" do
    it "可以发送" do
      post "/api/v1/validation_codes", params: {email: "a492073467@gmail.com"}
      expect(response).to have_http_status 200
    end
  end
end
