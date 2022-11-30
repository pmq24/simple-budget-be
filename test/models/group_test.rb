require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'should save group when name, kind, user_id is provided and user_id exists and kind is valid' do
    user = User.new email: 'test@example.com', password_hash: 'abc'
    assert user.save, 'Failed to setup - Failed to create user'

    group = Group.new name: 'test', kind: 'income', user_id: user.id
    assert group.save, 'Failed to create group'
  end

  test 'should save group when name and user_id are unique (different users can have groups with the same name)' do
    user1 = User.new email: 'test1@example.com', password_hash: 'abc'
    assert user1.save, 'Failed to setup - Failed to create user1'

    user2 = User.new email: 'test2@example.com', password_hash: 'abc'
    assert user2.save, 'Failed to setup - Failed to create user2'

    group_name = 'monthly bill'

    group1 = Group.new name: group_name, kind: 'expense', user_id: user1.id
    assert group1.save, 'Failed to create group1'

    group2 = Group.new name: group_name, kind: 'expense', user_id: user2.id
    assert group2.save, 'Failed to create group2'
  end

  test 'should not save group when user create groups with same name' do
    user = User.new email: 'test@example.com', password_hash: 'abc'
    assert user.save, 'Failed to setup - Failed to create user'

    name = 'monthly bill'
    kind = 'expense'
    user_id = user.id

    group1 = Group.new name: name, kind: kind, user_id: user_id
    assert group1.save, 'Failed to setup - Failed to create group'

    group2 = Group.new name: name, kind: kind, user_id: user_id
    assert_not group2.save,
               'Group saved, even user has created a group with the same name before'
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
