require "rails_helper"

RSpec.describe "Tags", type: :request do
  describe "获取标签" do
    it "未登录获取" do
      get "/api/v1/tags"
      expect(response).to have_http_status 401
    end
    it "已登录获取" do
      user1 = User.create email: "1@qq.com"
      user2 = User.create email: "2@qq.com"
      11.times { |i| Tag.create name: "tag#{i}", sign: "x", user_id: user2.id }
      11.times { |i| Tag.create name: "tag#{i}", sign: "x", user_id: user1.id }

      get "/api/v1/tags", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["resources"].size).to eq 10
      expect(json["resources"][0]["user_id"]).to eq user1.id

      get "/api/v1/tags", headers: user1.generate_auth_header, params: {page: 2}
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["user_id"]).to eq user1.id
    end
  end
  describe "创建标签" do
    it "未登录创建" do
      post "/api/v1/tags", params: {name: "tag", sign: "x"}
      expect(response).to have_http_status 401
    end
    it "已登录创建" do
      user = User.create email: "1@qq.com"
      post "/api/v1/tags", params: {name: "tag", sign: "x"}, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["resource"]["user_id"]).to eq user.id
      expect(json["resource"]["name"]).to eq "tag"
      expect(json["resource"]["sign"]).to eq "x"
    end
    it "已登录创建，name 为空" do
      user = User.create email: "1@qq.com"
      post "/api/v1/tags", params: {sign: "x"}, headers: user.generate_auth_header
      expect(response).to have_http_status 422
      json = JSON.parse response.body
      expect(json["errors"]["name"][0]).to eq "can't be blank"
    end
    it "已登录创建，sign 为空" do
      user = User.create email: "1@qq.com"
      post "/api/v1/tags", params: {name: "tag"}, headers: user.generate_auth_header
      expect(response).to have_http_status 422
      json = JSON.parse response.body
      expect(json["errors"]["sign"][0]).to eq "can't be blank"
    end
  end
end
