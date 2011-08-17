require File.dirname(__FILE__) + '/../test_helper'

class SessionControllerTest < ActionController::TestCase
  fixtures :users, :groups, :sites, :tokens

  def test_should_login_and_redirect
    get :login
    assert_response :success

    post :login, :login => 'quentin', :password => 'quentin'
    assert session[:user]
    assert_response :redirect
    assert_redirected_to '/me'
  end

  def test_should_fail_login_and_not_redirect
    post :login, :login => 'quentin', :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    post :logout
    assert_nil session[:user]
    assert_response :redirect
  end

#  def test_should_remember_me
#    post :login, :login => 'quentin', :password => 'quentin', :remember_me => "1"
#    assert_not_nil @response.cookies["auth_token"]
#  end

#  def test_should_not_remember_me
#    post :login, :login => 'quentin', :password => 'quentin', :remember_me => "0"
#    assert_nil @response.cookies["auth_token"]
#  end

 # repeat_with_sites(:local => {:signup_mode => Conf::SIGNUP_MODE[:verify_email]}) do
#  def test_login_without_verification_should_remind_to_verify
#    gerrard = users(:gerrard)
#    gerrard.update_attribute(:unverified, true)
#    
#    post :login, :login => 'gerrard', :password => 'gerrard'
#    assert session[:user]
#    assert_response :redirect
#    assert_redirected_to :controller => 'account', :action => 'unverified'
#  end
  
  #end
  #def test_should_delete_token_on_logout
  #  login_as :quentin
  #  get :logout
  #  assert_equal @response.cookies["auth_token"], []
  #end

#  def test_should_fail_expired_cookie_login
#    users(:quentin).remember_me
#    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
#    @request.cookies["auth_token"] = cookie_for(:quentin)
#    get :index
#    assert !@controller.send(:logged_in?)
#  end

#  def test_should_fail_cookie_login
#    users(:quentin).remember_me
#    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
#    get :index
#    assert !@controller.send(:logged_in?)
#  end

#  protected

#  def cookie_for(user)
#    auth_token users(user).remember_token
#  end

#  def auth_token(token)
#    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
#  end

end
