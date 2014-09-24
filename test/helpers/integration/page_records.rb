module PageRecords

  def own_page(type = nil, options = {})
    options, type = type, nil  if type.is_a? Hash
    options.merge! :created_by => user
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
    #TODO: implement test for asset page creation with file upload
    type = :discussion_page if type == :asset_page
    type_name = I18n.t "#{type}_display"
    # create page is on a hidden dropdown
    # click_on :create_page.t
    visit '/pages/new/me'
    click_on type_name
    new_page(type, options)
    title = options[:title] || type_name + new_page.title.to_s
    fill_in :title.t, with: title
    fill_in(:summary.t, with: new_page.summary) if new_page.summary
    click_on :create.t
  end
end
