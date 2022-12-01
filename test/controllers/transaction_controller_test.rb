require 'test_helper'

class TransactionControllerTest < ActionDispatch::IntegrationTest
  test 'create - case 201' do
    sign_up_and_log_in

    post transactions_url,
         params: {
           amount: 1000,
           time: DateTime.now,
           group_id: @group.id,
         },
         as: :json

    assert_response :created
    assert_equal Transaction.where(user_id: @user.id).size,
                 1,
                 'Transaction was not saved into database'
  end

  test 'create - case 400 amount is missing' do
    sign_up_and_log_in

    post_data_to_create_transaction({ time: DateTime.now, group_id: @group.id })

    assert_response :bad_request, 'Incorrect status code'
  end

  test 'get all - case 200' do
    sign_up_and_log_in
    (1..5).each do |number|
      post_data_to_create_transaction(
        {
          amount: number,
          time: DateTime.now,
          user_id: @user.id,
          group_id: @group.id,
        },
      )
    end

    get transactions_url

    assert_response :success

    assert_equal Transaction.where(user_id: @user.id).size, 5
  end

  def sign_up_and_log_in
    email = 'test@example.com'
    password = 'password'

    group_name = 'test_group'

    post sign_up_url, params: { email: email, password: password }, as: :json
    assert_response :success, 'Failed to setup - Failed to sign up'

    @user = User.find_by(email: email)

    post log_in_url, params: { email: email, password: password }, as: :json
    assert_response :success, 'Failed to setup - Failed to log in'

    post groups_url, params: { name: group_name, kind: 'expense' }, as: :json
    assert_response :success, 'Failed to setup - Failed to create group'

    @group = Group.find_by(name: group_name)
  end

  def post_data_to_create_transaction(data)
    post transactions_url, params: data, as: :json
  end
end
