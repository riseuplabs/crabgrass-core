module Common::Utility::ContextHelper
  #
  # sets up the navigation variables from the current theme.
  #
  # The 'active' blocks of the navigation definition are evaluated in this
  # method, so any variables needed by those blocks must be set up before this
  # is called.
  #
  def current_navigation
    @navigation ||= begin
      navigation = {}
      navigation[:global] = current_theme.navigation.root
      if navigation[:global]
        navigation[:context] = navigation[:global].currently_active_item
        if navigation[:context]
          navigation[:local] = navigation[:context].currently_active_item
        end
      end
      navigation = setup_navigation(navigation) # allow controller change to modify @navigation
      navigation
    end
  end

  ##
  ## DETECTION
  ##

  #
  # returns true if the current display context matches the symbol.
  # options are :none, :me, :group, or :user
  #
  def context?(symbol)
    case symbol
      when :none  then @context.nil?
      when :me    then @context.is_a?(Context::Me)
      when :group then @context.is_a?(Context::Group)
      when :user  then @context.is_a?(Context::User)
    end
  end

end
