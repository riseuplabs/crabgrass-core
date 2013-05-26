
#require 'action_view/helpers/tag_helper'
#require 'active_view/helpers/java_script_helper'

require 'action_view/helpers'

module Formy

  class Element
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::JavaScriptHelper
    #include ActionView::Helpers::UrlHelper

    def initialize(form,options={})
      @base = form
      @opts = options
      if @opts[:hide]
        @opts[:style] = ['display:none;', @opts[:style]].combine
      end
      if @opts[:disabled]
        @opts[:class] = ['disabled', @opts[:class]].combine
      end
      @elements = []                     # sub elements held by this element
      @element_count = 0
      @buffer = Buffer.new
    end

    # takes "object.attribute" or "attribute" and spits out the
    # correct object and attribute strings.
    def get_object_attr(object_dot_attr)
      object =  object_dot_attr[/^([^\.]*)\./, 1] || @base.options['object']
      attr = object_dot_attr[/([^\.]*)$/]
      return [object,attr]
    end

    def push
      @base.depth += 1
      @base.current_element.push(self)
    end

    def pop
      @base.depth -= 1
      @base.current_element.pop
    end

    def open
      puts "<!-- begin #{self.classname} -->" if @opts[:annotate]
      push
    end

    def close
      pop
      puts "<!-- end #{self.classname} -->" if @opts[:annotate]
    end

    def classname
      self.class.to_s[/[^:]*$/].downcase
    end

    def to_s
      @buffer.to_s
    end

    def raw_puts(str)
      @buffer << str
    end

    def indent(str)
      if str.is_a? Array
        str.collect {|i|
          indent(i)
        }.join
      else
        ("  " * @base.depth) + str.to_s + "\n"
      end
    end

    def puts(str)
      @buffer << indent(str)
    end

    def puts_push(str)
      @buffer << indent(str)
      @base.depth += 1
    end

    def puts_pop(str)
      @base.depth -= 1
      @buffer << indent(str)
    end

    def parent
      @base.current_element[-2]
    end

    def tag(element_tag, value, options={})
      content_tag(element_tag, value, {:style => @opts[:style], :class => @opts[:class], :id => @opts[:id]})
    end

    def self.sub_element(*class_names)
      for class_name in class_names
        method_name = class_name.to_s.gsub(/^.*::/,'').downcase
        module_eval <<-"end_eval"
        def #{method_name}(options={})
          element = #{class_name}.new(@base,{:index => @element_count}.merge(options))
          element.open
          yield element
          element.close
          @elements << element
          @element_count += 1
        end
        end_eval
      end
    end

    #
    # define setters for attributes.
    #
    # if the value passed to the attribute setter is a string
    # then we append it to the attribute. otherwise, we replace it.
    #
    # if a block is given to the attribute setter, the result is
    # used as the value argument.
    #
    def self.element_attr(*attr_names)
      for a in attr_names
        a = a.id2name
        module_eval <<-"end_eval"
        def #{a}(*args)
          value = if block_given?
            yield
          elsif args.size == 1
            args.first
          else
            args
          end
          if value.is_a? String
            (@#{a} ||= '') << value
          elsif !value.nil?
            @#{a} = value
          end
        end
        end_eval
      end
    end

    # work around rails 2.3.5 to_json circular reference problem
    def to_json
      self.inspect
    end

  end

end

