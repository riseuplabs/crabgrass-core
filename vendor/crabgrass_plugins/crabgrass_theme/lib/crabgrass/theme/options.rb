##
## ThemeOptions - a simple class used to create a theme definitions
##

class Crabgrass::Theme::Options

  attr_reader :data

  def self.parse(theme, data, &block)
    opts = Crabgrass::Theme::Options.new(theme, data)
    if block
      opts.instance_eval(&block)
    end
    return opts.data
  end

  def initialize(theme, data={})
    @theme = theme
    @data = data
    @namespace = []
  end

  # method calls with blocks push a new namespace
  # everything else just captures the first argument as the value.
  def method_missing(name, *args, &block)
    name = name.to_s
    if block
      @namespace.push(name)
      instance_eval(&block)
      @namespace.pop
    else
      key = (@namespace + [name]).join('_').to_sym
      if args.length == 1
        value = args.first
      else
        value = args
      end
      @data[key] = value
    end
    nil
  end

  # this conflicts with a rake dsl otherwise
  def link(*args, &block)
    self.method_missing :link, *args, &block
  end

  def url(image_name)
    filename = @data[image_name.to_sym] || image_name
    File.join('','theme', @theme.name, 'images', filename)
  end

  def html(*args, &block)
    key = (@namespace + ['html']).join('_').to_sym
    value = args.first || block
    @data[key] = value
    nil
  end

  def var(variable_name)
    @data[variable_name]
  end

  #
  # like var(), but the variable name is determined dynamically.
  #
  def var_eval(*args)
    variable_name = args.collect { |arg|
      if arg.is_a? String
        arg
      elsif arg.is_a? Symbol
        var(arg)
      end
    }.join
    var(variable_name.to_sym)
  end
end

