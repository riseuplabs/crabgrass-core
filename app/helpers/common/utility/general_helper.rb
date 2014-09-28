module Common::Utility::GeneralHelper

  ##
  ## GENERAL UTILITY
  ##

  #
  # just like content_tag, but skips the tag if passed empty content.
  #
  def content_tag_if_any(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
    content = nil
    opts = nil
    if block
      opts = content_or_options_with_block
      content = yield block
    else
      opts = options
      content = content_or_options_with_block
    end
    if content.present?
      return content_tag(name, content, opts, escape)
    else
      return ""
    end
  end

  #
  # create ul list by calling block repeatedly for each item.
  #
  def ul_list_tag(items, options={}, &block)

    if (header = options.delete(:header))
      header_tag = content_tag(:li, header, class: 'header')
    else
      header_tag = ""
    end

    if (footer = options.delete(:footer))
      footer_tag = content_tag(:li, footer, class: 'footer')
    else
      footer_tag = ""
    end

    content_tag(:ul, options) do
      (header_tag +
       items.collect {|item| content_tag(:li, yield(item))}.join.html_safe +
        footer_tag).html_safe
    end
  end

  #
  # words that are very long with no spaces can break the layout badly.
  #
  # normally, it seems to work pretty good to add the css "word-wrap: break-word;"
  # to elements that might have really long words.
  #
  # i can't get this working for tables. instead, this method is used to manually
  # add in hidden hyphenation to the long word.
  #
  # see http://www.quirksmode.org/oddsandends/wbr.html
  #
  def force_wrap(text,max_length=20)
    h(text).gsub(/(\w{#{max_length},})/) do |word|
      split_up_word = word.scan(/.{#{max_length}}/)
      word_remainder = word.split(/.{#{max_length}}/).select{|str| str.present?}
      (split_up_word + word_remainder).join('&shy;')
    end.html_safe
  end

  # returns the first of the args where present? returns true
  # if none has any, return last
  def first_present(*args)
    for str in args
      return str if str.present?
    end
    return args.last
  end

  ## converts bytes into something more readable
  def friendly_size(bytes)
    return unless bytes
    if bytes > 1.megabyte
      '%s MB' % (bytes / 1.megabyte)
    elsif bytes > 1.kilobyte
      '%s KB' % (bytes / 1.kilobyte)
    else
      '%s B' % bytes
    end
  end

  #
  # returns true the first time it is called for 'key', and false otherwise.
  #
  def once?(key)
    @called_before ||= {}
    if @called_before[key]
      return false
    else
      @called_before[key] = true
      return true
    end
  end

  #
  # used to set the class 'first' for lists of things, because css selector :first
  # is not very reliable.
  #
  # for example:
  #
  #   .p{:class => first(:list)}   --->   <p class="first"></p>
  #   .p{:class => first(:list)}   --->   <p></p>
  #   .p{:class => first(:list)}   --->   <p></p>
  #
  def first(key)
    once?(key) ? 'first' : ''
  end

  def logged_in_since
    session[:logged_in_since] || Time.now
  end

  #
  # if method is a proc or a symbol for a defined method, then it is called.
  # otherwise, nothing happens.
  #
  def safe_call(method, *args)
    if method.is_a? Proc
      method.call(*args)
    elsif method.is_a?(Symbol) && self.respond_to?(method)
      send(method, *args)
    else
      false
    end
  end

  # from http://www.igvita.com/2007/03/15/block-helpers-and-dry-views-in-rails/
  # Only need this helper once, it will provide an interface to convert a block into a partial.
  # 1. Capture is a Rails helper which will 'capture' the output of a block into a variable
  # 2. Merge the 'body' variable into our options hash
  # 3. Render the partial with the given options hash. Just like calling the partial directly.
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(body: capture(&block))
    concat(render(partial: partial_name, locals: options))
  end

  def browser_is_ie?
    user_agent = request.env['HTTP_USER_AGENT'].try.downcase
    user_agent =~ /msie/ and user_agent !~ /opera/
  end

end
