class AdminMailer < Mailer
  def blast(user, options)
    setup(options)
    setup_user(user)
    @subject += options[:subject]
    @message = options[:body]
    mail from: @from_address, to: user.email, subject: @subject
  end


  def notify_inappropriate(user, options)
    setup(options)
    setup_user(user)
    @subject += "Inappropriate Content"
    @message = options[:body]
    @url = link(options[:url])
    @owner = options[:owner]
    mail from: @from_address, to: user.email, subject: @subject
  end

  protected

  def setup_user(user)
    @subject    = @site.title + ": "
    @user = user
  end

end
