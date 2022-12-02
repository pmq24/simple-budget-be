class ApplicationAuthController < ApplicationController
  def persist_user(user)
    session[:user_id] = user.id
  end

  def get_logged_in_user
    return nil if not session.key? :user_id

    return User.find_by id: session[:user_id]
  end
end

UNAUTHORIZED_RESPONSE_BODY = { message: 'You must log in' }
