define_navigation(parent: 'default') do
  global_section :me do
    # remove_section(:activities)
    remove_section(:messages)
    context_section :settings do
      remove_section(:permissions)
    end
  end

  global_section :group do
    context_section :settings do
      remove_section(:permissions)
    end
  end
end
