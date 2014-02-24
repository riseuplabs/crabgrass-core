module AccountManagement
  def signup
    @user ||= FactoryGirl.build :user
    @user.display_name = nil
    click_on :signup_link.t
    fill_in :signup_login_name.t, with: @user.login
    fill_in :signup_password.t, with: @user.password
    fill_in :signup_confirm_password.t, with: @user.password
    click_on :signup_button.t
  end

  def login
    # Create a user wihtout the lengthy signup procedure
    @user ||= FactoryGirl.create :user
    visit '/' unless page.current_path == '/'
    fill_in :login_name.t, with: @user.login
    fill_in :login_password.t, with: @user.password
    click_on :login_button.t
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
  # log you in as that user and run te code block.
  # It also takes an array of users and does so for each one in turn.
  def as_a(users,&block)
    if users.respond_to? :each
      users.each{ |user| as_a(user, &block) }
    else
      run_for_user(users, &block)
    end
  end

  def run_for_user(current_user, &block)
    @run ||= 0
    @run += 1
    @user = current_user
    login unless @user.is_a? UnauthenticatedUser
    block.arity == 1 ? yield(@user) : yield
    Capybara.reset_sessions!
  rescue MiniTest::Assertion => e
    # preserve the backtrace but add the run number to the message
    raise $!, "#{$!} in run #{@run}", $!.backtrace
  end
end
