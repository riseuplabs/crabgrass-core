##
## NAVIGATION ITEM
##
## A navigation item represents a single link in the navigation tree.
## As a tree, each item can have many children.
##

class Crabgrass::Theme::NavigationItem < Array

  attr_reader :name
  ATTRIBUTES = [:label, :url, :active, :active?, :visible, :visible?, :html, :icon]

  def initialize(name, theme)
    @name = name
    @theme = theme
    @pointer = 0
    @visible = true
  end

  # allow reassignment of theme object. 
  # recursively descends the tree, reassigning theme.
  # this is necessary when we duplicate a tree for theme inheritance.
  def theme=(new_theme)
    @theme = new_theme
    each do |item|
      item.theme = new_theme
    end
  end

  def [](key)
    self.send(key) if ATTRIBUTES.include?(key)
  end

  def current
    self[@pointer]
  end

  def add(elem)
    push(elem)
    @pointer += 1
    elem
  end

  #
  # finds the element with the given name. does not decend the tree.
  # this is needed so that navigation definitions can add items to
  # pre-existing trees.
  #
  def seek(name)
    each_with_index do |elem, i|
      if elem.name == name
        @pointer = i
        return elem
      end
    end
    @pointer = -1 # could not find it
    nil
  end

  def seek_last
    @pointer = length - 1
  end

  #
  # removes the named sub navigation item
  #
  def remove(name)
    seek(name)
    remove_current
  end

  #
  # removes the current() navigation item (ie, one pointed to by @pointer).
  #
  def remove_current
    if @pointer >= 0
      item = self.delete_at(@pointer)
      seek_last
      return item
    end
  end

  # used for debugging
  #
  def inspect
    "[#{@name}: #{collect {|i| i.inspect}.join(',')}]"
  end

  #
  # defines an attribute by creating the setting and getter methods needed.
  # raises an exception if the attribute is not in ATTRIBUTES.
  #
  def set_attribute(name, value)
    if !ATTRIBUTES.include?(name)
      raise 'ERROR in theme definition: "%s" is not a known attribute.' % name
    else
      name = name.to_s.chop if name.to_s =~ /\?$/
      instance_variable_set("@#{name}", value)
    end
  end
  
  #
  # define the getters for our attributes.
  # if the value of an attribute is a Proc, then we eval it in the context
  # of the controller.
  #
  ATTRIBUTES.each do |attr_name|
    attr_name = attr_name.to_s
    if attr_name =~ /\?$/
      attr_name.chop!
      define_method(attr_name + '?') do
        send(attr_name)
      end
    else
      define_method(attr_name) do
        value = instance_variable_get("@#{attr_name}")
        if value.is_a?(Proc) and @theme.controller
          @theme.controller.instance_eval(&value)
        else
          value
        end
      end
    end
  end

  #
  # currently_active_item returns the first sub-tree that is currently active, if any.
  #
  def currently_active_item
    detect{|i| i.active? && i.visible?}
  end
end

