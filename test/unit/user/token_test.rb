require 'test_helper'

class User::TokenTest < ActiveSupport::TestCase


  def test_create
    token = User::Token.new(user: users(:blue))
    token.save
    assert_equal 20, token.value.length
    assert !token.expired?
  end

  def test_expired
    assert tokens(:tokens_001).expired?
    assert !tokens(:tokens_003).expired?
  end

  def test_token_to_recover
    token = User::Token.to_recover.new(user: users(:blue))
    assert_equal 'recovery', token.action
    assert_equal users(:blue).id, token.user_id
  end

  def test_find_token
    token = User::Token.to_recover.create(user: users(:blue))
    assert_equal token, User::Token.to_recover.active.find_by_param(token.to_param)
    assert_nil User::Token.active.find_by_param(User::Token.new.to_param)
  end
end
