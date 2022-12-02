require "rails_helper"
require "rspec_api_documentation/dsl"

resource "会话" do
  post "api/v1/session" do
    header "Content-Type", "application/json"
    parameter :email, "邮箱", required: true, type: :string
    parameter :code, "验证码", required: true, type: :string

    let(:email) { "test@qq.com" }
    let(:code) { "123456" }

    example "登录" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["jwt"]).to be_a String
    end
  end
end
