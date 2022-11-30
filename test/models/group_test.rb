require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'should save group when name, kind, user_id is provided and user_id exists and kind is valid' do
    user = User.new email: 'test@example.com', password_hash: 'abc'
    assert user.save, 'Failed to setup - Failed to create user'

    group = Group.new name: 'test', kind: 'income', user_id: user.id
    assert group.save, 'Failed to create group'
  end

  test 'should not save group when name is missing' do
    user = User.new email: 'test@example.com', password_hash: 'abc'
    assert user.save, 'Failed to setup - Failed to create user'

    group = Group.new kind: 'income', user_id: user.id
    assert_not group.save, 'Group saved, even without name'
  end

  test 'should not save group when kind is missing' do
    user = User.new email: 'test@example.com', password_hash: 'abc'
    assert user.save, 'Failed to setup - Failed to create user'

    group = Group.new name: 'test', user_id: user.id
    assert_not group.save, 'Group saved, even without kind'
  end

  test 'should not save group when kind is not `income` or `expense`' do
    user = User.new email: 'test@example.com', password_hash: 'abc'
    assert user.save, 'Failed to setup - Failed to create user'

    group = Group.new name: 'test', user_id: user.id, kind: 'not valid kind'
    assert_not group.save, 'Group saved, even with invalid kind'
  end

  test 'should not save group when user_id is missing' do
    group = Group.new name: 'test', kind: 'not valid kind'
    assert_not group.save, 'Group saved, even without user_id'
  end

  test 'should not save group when user doesnt exist' do
    group = Group.new name: 'test', kind: 'not valid kind', user_id: 999
    assert_not group.save, 'Group saved, even without user_id'
  end
end
