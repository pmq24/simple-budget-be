require 'digest'
require 'json'

require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest
  class SignUpTest < ActionDispatch::IntegrationTest
    errors_of_model_user = 'activerecord.errors.models.user.attributes'

    test 'case 201' do
      email = 'test@example.com'
      password = 'abc'
      hashed_password = Digest::SHA256.hexdigest(password)

      post sign_up_url, params: { email: email, password: password }, as: :json

      created_user = User.find_by(email: email)

      assert_not_nil created_user, 'User has not been saved to the database'

      assert_equal created_user.password_hash,
                   hashed_password,
                   'Password was hashed incorrectly'

      assert_response :created, 'Incorrect status code'

      body = JSON.parse @response.body
      data = body['data']
      assert_equal email, data['email'], 'Incorrect data'
    end

    test 'case 400 email not provided' do
      post sign_up_url, params: { password: 'abc' }, as: :json

      assert_response 400
      body = JSON.parse @response.body
      email_errors = body['errors']['email']
      assert_includes email_errors,
                      I18n.t("#{errors_of_model_user}.email.blank"),
                      'errors.email doesnt include blank error'
    end

    test 'case 400 password not provided' do
      post sign_up_url, params: { email: 'test@example.com' }, as: :json

      assert_response 400, 'Incorrect status code'
      body = JSON.parse @response.body
      password_error = body['errors']['password_hash']
      assert_includes password_error,
                      I18n.t("#{errors_of_model_user}.password_hash.blank"),
                      'Incorrect error message'
    end

    test 'case 409' do
      email = 'test@example.com'
      post sign_up_url, params: { email: email, password: 'abc' }, as: :json

      assert_not_nil User.find_by(email: email),
                     'Failed to setup - User was not saved to the database'

      post sign_up_url, params: { email: email, password: 'abc' }, as: :json

      assert_response 409, 'Incorrect status code'

      body = JSON.parse @response.body
      errors = body['errors']
      email_errors = errors['email']

      assert_includes email_errors,
                      I18n.t("#{errors_of_model_user}.email.taken"),
                      'Incorrect error message'
    end
  end

  class LogInTest < ActionDispatch::IntegrationTest
    test 'case 200' do
      email = 'test@example.com'
      password = 'abc'

      post sign_up_url, params: { email: email, password: password }, as: :json

      assert_response :success,
                      'Failed to setup - User was not registered to the database'

      post log_in_url, params: { email: email, password: password }, as: :json
      assert_response :success, 'Failed to log in'
      assert_not_nil controller.session[:user_id],
                     'User ID was not persisted in session'
    end
  end
end
