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
  describe "修改标签" do
    it "未登录修改" do
      user = User.create email: "1@qq.com"
      tag = Tag.create name: "tag", sign: "x", user_id: user.id

      patch "/api/v1/tags/#{tag.id}", params: {name: "tag_modify", sign: "y"}
      expect(response).to have_http_status 401
    end
    it "修改自己的标签" do
      user = User.create email: "1@qq.com"
      tag = Tag.create name: "tag", sign: "x", user_id: user.id

      patch "/api/v1/tags/#{tag.id}", params: {name: "tag_modify", sign: "y"}, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["resource"]["name"]).to eq "tag_modify"
      expect(json["resource"]["sign"]).to eq "y"
    end
    it "部分修改自己的标签" do
      user = User.create email: "1@qq.com"
      tag = Tag.create name: "tag", sign: "x", user_id: user.id

      patch "/api/v1/tags/#{tag.id}", params: {name: "tag_modify"}, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["resource"]["name"]).to eq "tag_modify"
      expect(json["resource"]["sign"]).to eq "x"
    end
    it "修改不属于自己的标签" do
      current_user = User.create email: "1@qq.com"
      other_user = User.create email: "2@qq.com"
      tag = Tag.create name: "tag", sign: "x", user_id: other_user.id

      patch "/api/v1/tags/#{tag.id}", params: {name: "tag_modify", sign: "y"}, headers: current_user.generate_auth_header
      expect(response).to have_http_status 403
    end
  end

  describe "删除标签" do
    it "未登录删除" do
      user = User.create email: "1@qq.com"
      tag = Tag.create name: "tag", sign: "x", user_id: user.id

      delete "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status 401
    end
    it "删除自己的标签" do
      user = User.create email: "1@qq.com"
      tag = Tag.create name: "tag", sign: "x", user_id: user.id

      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      tag.reload
      expect(tag.deleted_at).not_to eq nil
    end
    it "删除不属于自己的标签" do
      current_user = User.create email: "1@qq.com"
      other_user = User.create email: "2@qq.com"
      tag = Tag.create name: "tag", sign: "x", user_id: other_user.id

      delete "/api/v1/tags/#{tag.id}", headers: current_user.generate_auth_header
      expect(response).to have_http_status 403
      expect(tag.deleted_at).to eq nil
    end
  end

  describe "获取单个标签" do
    it "未登录获取" do
      user = User.create email: "1@qq.com"
      tag = Tag.create name: "tag", sign: "x", user_id: user.id

      get "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status 401
    end
    it "获取不存在的标签" do
      user = User.create email: "1@qq.com"

      get "/api/v1/tags/1", headers: user.generate_auth_header
      expect(response).to have_http_status 404
    end
    it "获取自己的标签" do
      user = User.create email: "1@qq.com"
      tag = Tag.create name: "tag", sign: "x", user_id: user.id

      get "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["resource"]["id"]).to eq tag.id
      expect(json["resource"]["name"]).to eq "tag"
      expect(json["resource"]["sign"]).to eq "x"
    end
    it "获取不属于自己的标签" do
      current_user = User.create email: "1@qq.com"
      other_user = User.create email: "2@qq.com"
      tag = Tag.create name: "tag", sign: "x", user_id: other_user.id

      get "/api/v1/tags/#{tag.id}", headers: current_user.generate_auth_header
      expect(response).to have_http_status 403
    end
  end
end
