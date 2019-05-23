module Common::Utility::GeneralHelper
  #
  # create ul list by calling block repeatedly for each item.
  #
  def ul_list_tag(items, options = {})
    header_tag = if (header = options.delete(:header))
                   content_tag(:li, header, class: 'header')
                 else
                   ''
                 end

    footer_tag = if (footer = options.delete(:footer))
                   content_tag(:li, footer, class: 'footer')
                 else
                   ''
                 end

    content_tag(:ul, options) do
      (header_tag +
       items.collect { |item| content_tag(:li, yield(item)) }.join.html_safe +
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
  def force_wrap(text, max_length = 20)
    h(text).gsub(/(\w{#{max_length},})/) do |word|
      split_up_word = word.scan(/.{#{max_length}}/)
      word_remainder = word.split(/.{#{max_length}}/).select(&:present?)
      (split_up_word + word_remainder).join('&shy;')
    end.html_safe
  end

  # returns the first of the args where present? returns true
  # if none has any, return last
  def first_present(*args)
    for str in args
      return str if str.present?
    end
    args.last
  end

  # converts bytes into something more readable
  def friendly_size(bytes)
    return unless bytes
    if bytes > 1.megabyte
      format('%s MB', (bytes / 1.megabyte))
    elsif bytes > 1.kilobyte
      format('%s KB', (bytes / 1.kilobyte))
    else
      format('%s B', bytes)
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
end
