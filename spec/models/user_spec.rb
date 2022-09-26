require "rails_helper"

RSpec.describe User, type: :model do
  it "有 email" do
    user = User.new email: "zjn@123.com"
    expect(user.email).to eq "zjn@123.com"
  end
end
