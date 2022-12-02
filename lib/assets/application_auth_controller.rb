class ApplicationAuthController < ApplicationController
  protect_from_forgery with: :null_session

  def persist_user(user)
    session[:user_id] = user.id
  end

  def get_logged_in_user
    return User.find_by id: session[:user_id]
  end
end

UNAUTHORIZED_RESPONSE_BODY = { message: 'You must log in' }
