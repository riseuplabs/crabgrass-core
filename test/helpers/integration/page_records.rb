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
    if type
      @page = records[type] ||= FactoryGirl.build(type, options)
    else
      @page ||= FactoryGirl.build(:discussion_page, options)
    end
  end

  def create_page(type, options = {})
    type_name = I18n.t "#{type}_display"
    # create page is on a hidden dropdown
    # click_on :create_page.t
    visit '/pages/new/me'
    click_on type_name
    new_page(type, options)
    title = options[:title] || type_name + new_page.title.to_s
    file = options[:file] || fixture_file('bee.jpg')
    try_to_fill_in :title.t,   with: title
    try_to_fill_in :summary.t, with: new_page.summary
    try_to_attach_file :asset_uploaded_data, file
    click_on :create.t
    if type == :asset_page
      new_page.title = file.basename(file.extname)
    end
  end
end
