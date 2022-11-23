class UserMailer < ApplicationMailer
  def welcome_email(code)
    @code = code
    mail(to: "zhuangjinan2018@gmail.com", subject: "Welcome to My Awesome Site")
  end
end
