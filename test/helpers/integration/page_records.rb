module PageRecords

  def own_page(type = nil, options = {})
    options, type = type, nil  if type.is_a? Hash
    options.merge! created_by: user
    page = new_page(type, options)
    page.save
    page
  end

  def with_page(types)
    assert_for_all types do |type|
      yield new_page(type)
    end
  end

  def new_page(type=nil, options = {})
    options, type = type, nil  if type.is_a? Hash
    page_options = options.slice :title, :summary, :created_by, :owner
    if type
      @page = records[type] ||= FactoryGirl.build(type, page_options)
    else
      @page ||= FactoryGirl.build(:discussion_page, page_options)
    end
  end

  def create_page(type, options = {})
    type_name = I18n.t "#{type}_display"
    # create page is on a hidden dropdown
    # click_on :create_page.t
    visit '/pages/create/me'
    click_on type_name
    new_page(type, options)
    fill_in_new_page_form(type, options)
    click_on :create.t
  end

  def fill_in_new_page_form(type, options)
    title = options[:title] || "#{type} - #{new_page.title}"
    file = options[:file] || fixture_file('bee.jpg')
    try_to_fill_in :title.t,      with: title
    try_to_fill_in :summary.t,    with: new_page.summary
    add_recipients(*options[:share_with])
    try_to_attach_file :asset_uploaded_data, file
    # workaround for having the right page title in the test record
    new_page.title = file.basename(file.extname) if type == :asset_page
  end

  def add_recipients(*recipients)
    return if recipients.blank?
    click_on 'Additional Access'
    recipients.each do |rec|
      # TODO: find out why this misses the first letter on the
      # first attempt
      fill_in :recipients.t, with: rec.name, visible: true
      fill_in :recipients.t, with: rec.name, visible: true
      find('#add_recipient_button').click
    end
    # this may be in an error message or the list of shares.
    assert_content recipients.last.name
  end


end
