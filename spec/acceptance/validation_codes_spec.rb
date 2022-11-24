require "rails_helper"
require "rspec_api_documentation/dsl"

resource "验证码" do
  post "api/v1/validation_codes" do
    header "Content-Type", "application/json"

    # This is manual way to describe complex parameters
    parameter :email, type: :string

    let(:email) { "a492073467@gmail.com" }

    example "发送验证码" do
      expect(UserMailer).to receive(:welcome_email).with(email)
      do_request
      expect(status).to eq 200
      expect(response_body).to eq " "
      do_request
      expect(status).to eq 429
    end
  end
end
