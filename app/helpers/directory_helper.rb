module DirectoryHelper

  def directory_search(type)
    render 'common/directory/search'
  end

  #
  # render a formated list of all items in the collection
  # using the given partial for each entry
  #
  def directory_list(partial, collection)
    render :partial => 'common/directory/list',
      :locals => { :collection => collection, :partial => partial }
  end

end
