class UsersController < ApplicationController
  def create
    user = User.new email: 'zhuangji@x.com', name: 'Zhuangjinan'
    if user.save
      p 'save 成功'
    else
      p 'save 失败'
    end
  end

  def show
    p 'show'
  end
end
