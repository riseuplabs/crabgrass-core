class RequestNotice < Notice

  alias_attr :request, :noticable

  class << self
    alias_method :find_all_by_request, :find_all_by_noticable
    alias_method :destroy_all_by_request, :destroy_all_by_noticable

    #
    # like normal create!, but optionally takes a single arg that is a request object.
    #
    def create!(*args)
      if !args.first.is_a? Request
        super(*args)
      else
        request = args.first
        if request.recipient.nil?
          nil
        elsif request.recipient.is_a? Group
          request.recipient.users.each do |user|
            create!(request: request, user: user)
          end
        else
          create!(request: request, user: request.recipient)
        end
      end
    end

  end

  def button_text
    :show_thing.t(thing: :request.t)
  end

  def display_label
    :request.t
  end

  def display_body
    display_attr(:body).html_safe
  end

  def noticable_path
    :me_request_path
  end

  protected

  before_create :encode_data
  def encode_data
    self.data = { 
      body: request.description, 
      title: request.i18n_key_with_scope
    }
  end

  before_create :set_avatar
  def set_avatar
    # we always display the person issuing the request.
    # That way it matches the message notification
    self.avatar_id = request.created_by.avatar_id
  end

end
