require 'cgi'

class Notice::PageNotice < Notice
  alias_attr :page, :noticable
  attr_accessor :message
  attr_accessor :from

  class << self
    alias for_page for_noticable

    #
    # like normal create!, but optionally takes these additional args:
    #
    # * :recipients -- array of users to send to
    # * :message -- text message to send to users
    # * :from -- the user sending this notice
    #
    def create!(args = {})
      if recipients = args.delete(:recipients)
        recipients.each do |user|
          create!(args.merge(user: user))
        end
      else
        super(args) unless args[:user_id] ==  args[:page].updated_by_id
      end
    end
  end

  ##
  ## DISPLAY
  ##

  def display_title
    props = data.merge(
      page_title: CGI.escapeHTML(data[:page_title]),
      from: CGI.escapeHTML(data[:from]),
      message: CGI.escapeHTML(data[:message])
    )
    if !data[:message].empty?
      :page_notice_title_with_message.t(props).html_safe
    else
      :page_notice_title.t(props).html_safe
    end
  end

  def display_body_as_quote?
    true
  end

  def display_body
    data[:message]
  end

  def button_text
    :show_thing.t(thing: :page.t)
  end

  def display_label
    :page_notice.t
  end

  def redirect_path
    :page_path
  end

  protected

  before_create :encode_data
  def encode_data
    self.data = { message: message, from: from.name, page_title: page.title }
  end

  before_create :set_avatar
  def set_avatar
    self.avatar_id = from.avatar_id if from
  end
end
