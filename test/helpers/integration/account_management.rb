module AccountManagement
  def signup
    @user ||= FactoryGirl.build :user
    @user.display_name = nil
    click_on :signup_link.t
    fill_in 'user_login', with: @user.login
    fill_in 'user_password', with: @user.password
    fill_in 'user_password_confirmation', with: @user.password
    click_on :signup_button.t
  end

  def login(user = nil)
    # Create a user wihtout the lengthy signup procedure
    records[:user] ||= @user ||= user || FactoryGirl.create(:user)
    visit '/' unless page.current_path == '/'
    fill_in :login_name.t, with: @user.login
    fill_in :login_password.t, with: @user.password || @user.login
    click_button :login_button.t
  end

  def logout
    click_on :menu_link_logout.t(user: @user.display_name)
  end

  def destroy_account
    click_on :settings.t
    click_on :destroy.t
    click_button :destroy.t
  end

  # this function can take a single user as the argument and will
  # log you in as that user and run the code block.
  # It also takes an array of users and does so for each one in turn.
  def as_a(users,&block)
    assert_for_all users do |user|
      run_for_user(user, &block)
    end
  end

  def run_for_user(current_user, &block)
    @user = current_user
    login unless @user.is_a? UnauthenticatedUser
    block.arity == 1 ? yield(@user) : yield
  ensure
    clear_session
  end
end
