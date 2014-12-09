# We have a very flexible but yet restful routes for page items.
# They allow specifying the controller while still having the default
# restful properties and creating the normal named routes.
#
# It's a bit cumbersome though to always specify the page and the controller.
# So we add meaningful defaults to the named_route helpers here.
#
# What are meaningful defaults? Most page types have at least two controllers.
# One for the page itself and one for its items. So we want the second one.
# In order for this to work you have to make sure though the default controller
# for the items is listed at the second position in the init.rb file of the page.
#
# We only use the _url helpers for these - not the _path ones.
# Why?
# because the url includes https as the protocol. So even if the html snippet
# get's displayed out of context it will not initiate an unencrypted connection
# by accident. We can discuss this choice though.
#   *azul

module Common::Page::UrlHelper

  def sort_page_items_url(*args)
    add_page_item_defaults_to_args! args
    super
  end

  def page_items_url(*args)
    add_page_item_defaults_to_args! args
    super
  end

  def page_item_url(*args)
    add_page_item_defaults_to_args! args
    super
  end

  def edit_page_item_url(*args)
    add_page_item_defaults_to_args! args
    super
  end

  def add_page_defaults_to_args!(args)
    if @page.present?
      # use the default item controller not the main one
      controller = @page.controller
      add_defaults_to_args! args, page_id: @page, controller: controller
    end
  end

  def add_page_item_defaults_to_args!(args)
    if @page.present?
      # use the default item controller not the main one
      controller = @page.controllers.second || @page.controller
      add_defaults_to_args! args, page_id: @page, controller: controller
    end
  end

  def add_defaults_to_args!(args, defaults={})
    arg_options = args.extract_options!
    arg_options.reverse_merge! defaults
    args << arg_options
  end
end
