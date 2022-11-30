require 'test_helper'

class GroupControllerTest < ActionDispatch::IntegrationTest
  def sign_up_and_log_in
    email = 'test@example.com'
    password = 'abc'

    post sign_up_url, params: { email: email, password: password }, as: :json

    assert_response :success, 'Failed to setup - Failed to sign up'
    assert_not_nil User.find_by(email: email),
                   'Failed to setup - User was not saved to the database'

    post log_in_url, params: { email: email, password: password }, as: :json
    assert_response :success, 'Failed to setup - Failed to log in'

    assert_not_nil controller.session[:user_id],
                   'Failed to setup - User ID was not persisted in the session'

    return User.find_by_email(email)
  end

  test 'create - case 201' do
    user = sign_up_and_log_in

    name = 'monthly bills'
    kind = 'expense'

    post groups_url, params: { name: name, kind: kind }, as: :json

    assert_not_nil Group.find_by(name: name), 'Group was not created'

    assert_response :created, 'Failed to create group'

    body = JSON.parse @response.body
    data = body['data']
    assert_equal data['name'],
                 name,
                 'Created group\' name doesn\'t match what was provided'

    assert_equal data['kind'],
                 kind,
                 'Created group\' kind doesn\'t match what was provided'

    assert_equal data['user_id'],
                 user.id,
                 'Created group\' user_id doesn\'t match the currently logged in user'
  end

  test 'create - case 400 name was not provided' do
    sign_up_and_log_in

    kind = 'expense'

    post groups_url, params: { kind: kind }, as: :json
    assert_response :bad_request, 'Incorrect status code'
    assert_nil Group.find_by_name(name), 'Group was created, even without name'
  end

  test 'create - case 400 kind was not provided' do
    sign_up_and_log_in

    name = 'monthly bills'

    post groups_url, params: { name: name }, as: :json
    assert_response :bad_request, 'Incorrect status code'
    assert_nil Group.find_by_name(name), 'Group was created, even without kind'
  end

  test 'create - case 400 kind was not `income` or `expense`' do
    sign_up_and_log_in

    name = 'monthly bills'
    kind =
      'this is invalid kind because kind only accepts `income` and `expense`'

    post groups_url, params: { name: name, kind: kind }, as: :json
    assert_response :bad_request, 'Group was created, even with invalid kind'
    assert_nil Group.find_by_name(name),
               'Group was saved to the database, even with invalid kind'
  end

  test 'create - case 409 name already exists' do
    sign_up_and_log_in

    name = 'monthly bills'
    kind = 'expense'

    post groups_url, params: { name: name, kind: kind }, as: :json
    assert_response :created, 'Failed to setup - Failed to create group'
    assert_not_nil Group.find_by_name(name),
                   'Group was not saved to the database'

    post groups_url, params: { name: name, kind: kind }, as: :json
    assert_response :conflict, 'Incorrect status code'
  end

  test 'create - case 401 not logged in' do
    post groups_url, as: :json
    assert_response :unauthorized, 'Incorrect status code'
  end
end
