module OptionalFields

  def try_to_fill_in(locator, options = {})
    return if options[:with].blank?
    finder_options = options.except(:with, :fill_options)
    if has_selector?(:fillable_field, locator, finder_options)
      fill_in locator, options
    end
  end

  def try_to_attach_file(locator, path, options = {})
    return if path.blank?
    if has_selector?(:file_field, locator, options)
      attach_file locator, path, options
    end
  end
end
