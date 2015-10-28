module Autocomplete

  #
  # Try to fill in the field and make sure there is no matching autocomplete.
  #
  def assert_no_autocomplete(field, options)
    assert_raises Capybara::ElementNotFound do
      autocomplete field, options
    end
  end

  #
  # We fill in the autocomplete character by character.
  # As soon as the thing we are looking for shows up we click it.
  # Filling in the whole field would trigger tons of autocomplete requests.
  #
  # Note that this might still return before all requests have been answered
  # in particular if the term we are looking for is preloaded.
  # wait_for_ajax in here will NOT fix this. Sometimes the ajax request has
  # not been created yet when wait for ajax first checks.
  #
  def autocomplete(field, options)
    chars ||= 1
    # the space is a work around as the first letter may get cut off
    fill_in field, with: ' '
    fill_in field, with: options[:with][0,chars]
    # poltergeist will not keep the element focussed.
    # But when we loose focus the autocomplete won't show.
    execute_script("($('#{field}') || $$('[name=#{field}]')[0]).focus();")
    find('.autocomplete p', text: options[:with]).trigger('click')
  rescue Capybara::ElementNotFound
    chars +=1
    if chars > 3
      ENV['TRAVIS'] ? skip('autocomplete sometimes fails on travis') : raise
    end
    retry
  end
end
