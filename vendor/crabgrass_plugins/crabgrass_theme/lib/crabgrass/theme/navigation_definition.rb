##
## NAVIGATION DEFINITION
##

class Crabgrass::Theme::NavigationDefinition
  def self.parse(theme, parent_nav = nil, &block)
    tree = if parent_nav
             parent_nav.root.deep_clone
           else
             nil
           end
    navigation = Crabgrass::Theme::NavigationDefinition.new(theme, tree)
    if block
      # parse the navigation.rb file:
      navigation.instance_eval(&block)
    end
    navigation
  end

  def initialize(theme, tree = nil)
    @theme = theme
    if tree
      # work with an existing inherited tree
      @tree = tree
      @tree.theme = @theme
    else
      # create a new tree
      @tree = Crabgrass::Theme::NavigationItem.new('root', @theme)
    end
    @section_stack = []
    @section_stack << @tree
  end

  def method_missing(name, *args, &block)
    current = @section_stack.last
    if block
      current.set_attribute(name, block)
    else
      current.set_attribute(name, args.first)
    end
  end

  # creates a new section to the navigation. anything defined in the section
  # definition block is put under this section. if the named section already
  # exists, then we redefine it.
  #
  def section(name)
    section = current_section.seek(name) || current_section.add(Crabgrass::Theme::NavigationItem.new(name, @theme))
    @section_stack.push(section)
    yield
    @section_stack.pop
  end

  alias global_section section
  alias context_section section
  alias local_section section

  # removes the named section from the tree, at the *current* level
  # based on the section stack.
  def remove_section(name)
    current_section.remove(name)
  end

  def inspect
    @tree.inspect
  end

  def root
    @tree
  end

  #
  # section stack is a FILO stack of the sections.
  # we push a new section context onto the stack whenever 'section()' is called.
  #
  def current_section
    @section_stack.last
  end
end
