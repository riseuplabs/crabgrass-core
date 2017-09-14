module Mailers::Bugreport
  # Send an email letting the user know that a page has been 'sent' to them.
  def send_bugreport(params, options)
    setup(options)
    @backtrace         = params[:full_backtrace]
    @exception_class   = params[:execption_class]
    @error_controller  = params[:error_controller]
    @error_action      = params[:error_action]
    @exception_message = params[:exception_detailed_message]
    @comments          = params[:comments]
    mail from: @from_address,
         to: options[:dev_email],
         subject: 'Crabgrass Bug Report'
  end
end
