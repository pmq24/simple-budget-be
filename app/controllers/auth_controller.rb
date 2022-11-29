require 'digest'
require 'json'

class AuthController < ApplicationController
  protect_from_forgery with: :null_session

  def sign_up
    body = JSON.parse request.body.read

    password_hash =
      (body.key? 'password') ? (Digest::SHA256.hexdigest body['password']) : nil

    user = User.new(email: body['email'], password_hash: password_hash)

    if user.valid?
      user.save!
      render status: :created,
             json: {
               message: 'registered successfully',
               data: {
                 email: user.email,
               },
             }
      return
    end

    errors = user.errors

    only_has_conflict_error =
      (
        errors.size == 1 and errors.key?('email') and
          errors['email'].size == 1 and
          errors['email'][0] ==
            I18n.t('activerecord.errors.models.user.attributes.email.taken')
      )

    render status: only_has_conflict_error ? :conflict : :bad_request,
           json: {
             'message' =>
               'the provided data is invalid, refer to `errors` for details',
             'errors' => user.errors,
           }
  end

  def log_in
    body = JSON.parse request.body.read
    email = body['email']
    password = body['password']

    errors = Hash.new

    errors['email'] = ['email is required'] if email.blank?
    errors['password'] = ['password is required'] if password.blank?

    if not errors.empty?
      render status: :bad_request,
             json: {
               'message' =>
                 'the provided data is invalid, refer to `errors` for details',
               'errors' => errors,
             }
      return
    end

    user = User.find_by_email email

    if user.nil?
      render status: :not_found,
             json: {
               'message' => "the account #{email} was not registered",
             }
      return
    end

    password_hash = Digest::SHA256.hexdigest password
    if user.password_hash != password_hash
      render status: :bad_request, json: { 'message' => 'wrong password' }
      return
    end

    session[:user_id] = user.id

    render status: :ok,
           json: {
             'message' => "logged in successfully, welcome back #{email}!",
           }
  end
end
