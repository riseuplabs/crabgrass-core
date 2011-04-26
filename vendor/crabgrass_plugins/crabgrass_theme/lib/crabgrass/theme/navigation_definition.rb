##
## NAVIGATION DEFINITION
##

class Crabgrass::Theme::NavigationDefinition

  # for the theme to work, this controller must be set.
  # crabgrass sets it in a before_filter common to call controllers.
  # TODO: will this be a problem with multiple threads?
  attr_accessor :controller

  def self.parse(parent_nav=nil, &block)
    if parent_nav
      tree = parent_nav.root.dup
    else
      tree = nil
    end
    navigation = Crabgrass::Theme::NavigationDefinition.new(tree, &block)
    navigation.instance_eval(&block)
    return navigation
  end

  def initialize(tree=nil)
    if tree
      # work with an existing inherited tree
      @tree = tree
      @tree.navigation = self
    else
      # create a new tree
      @tree = Crabgrass::Theme::NavigationItem.new('root',self)
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
    section = current_section.seek(name) || current_section.add(Crabgrass::Theme::NavigationItem.new(name,self))
    @section_stack.push(section)
      yield
    @section_stack.pop
  end

  alias :global_section :section
  alias :context_section :section
  alias :local_section :section

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
