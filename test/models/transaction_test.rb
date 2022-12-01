require 'test_helper'
require 'date'

class TransactionTest < ActiveSupport::TestCase
  def setup
    @user = User.new email: 'test@example.com', password_hash: 'abc'
    assert @user.save, 'Failed to setup - Failed to create user'

    @group = Group.new name: 'test group', kind: 'expense', user_id: @user.id
    assert @group.save,
           "Failed to setup - Failed to create group with errors #{@group.errors.to_json}"
  end

  test 'should save transaction when amount is not negative, user_id is not nil and exists, group_id is not nil and exists' do
    transaction =
      Transaction.new amount: 1000,
                      time: DateTime.now,
                      user_id: @user.id,
                      group_id: @group.id
    assert transaction.save, 'Failed to create transaction'
  end

  test 'should not save transaction when amount is negative' do
    transaction =
      Transaction.new amount: -1000,
                      time: DateTime.now,
                      user_id: @user.id,
                      group_id: @group.id
    assert_not transaction.save,
               'Transaction created, even with negative amount'
  end

  test 'should not save transaction when amount is a string' do
    transaction =
      Transaction.new amount: 'not a number',
                      time: DateTime.now,
                      user_id: @user.id,
                      group_id: @group.id
    assert_not transaction.save,
               'Transaction created, even with a string amount'
  end

  test 'should not save transaction when user_id is missing' do
    transaction =
      Transaction.new amount: 1000, time: DateTime.now, group_id: @group.id
    assert_not transaction.save, 'Transaction created, even without user_id'
  end

  test 'should not save transaction when user_id doesnt exist' do
    transaction =
      Transaction.new amount: 1000,
                      time: DateTime.now,
                      user_id: 999,
                      group_id: @group.id
    assert_not transaction.save,
               'Transaction created, even with non-exist user_id'
  end

  test 'should not save transaction when group_id is missing' do
    transaction =
      Transaction.new amount: 1000, time: DateTime.now, user_id: @user.id
    assert_not transaction.save, 'Transaction created, even without group_id'
  end

  test 'should not save transaction when group_id doesnt exist' do
    transaction =
      Transaction.new amount: 1000,
                      time: DateTime.now,
                      user_id: @user.id,
                      group_id: 999
    assert_not transaction.save,
               'Transaction created, even with non-exist group_id'
  end
end
