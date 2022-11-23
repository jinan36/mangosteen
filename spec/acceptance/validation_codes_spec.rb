require "rails_helper"
require "rspec_api_documentation/dsl"

resource "验证码" do
  post "api/v1/validation_codes" do
    # This is manual way to describe complex parameters
    parameter :email, type: :string

    let(:email) { "test@gmail.com" }

    example "发送验证码" do
      do_request

      expect(status).to eq 200
    end
  end
end
