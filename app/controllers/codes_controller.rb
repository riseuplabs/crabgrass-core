class CodesController < ApplicationController

  # jump to the location of the code.
  def jump
    code = Page::AccessCode.find_by_code(params[:id])
    if code.nil? || code.expired?
      render :template => 'codes/not_found'
    elsif code.page
      redirect_to(page_url(code.page))
    else
      render :template => 'codes/not_found'
    end
  end

end
