class ApplicationAuthController < ApplicationController
  def persist_user(user)
    session[:user_id] = user.id
  end

  def get_logged_in_user
    if (session.key?(:user_id).nil?) or
         (User.find_by_id(session[:user_id]).nil?)
      return nil
    end
    return User.find_by_id session[:user_id]
  end
end
