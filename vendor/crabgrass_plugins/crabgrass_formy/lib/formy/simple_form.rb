# -*- coding: utf-8 -*-
#
# A simple stacked form, following bootstrap markup.
#
# http://getbootstrap.com/css/#forms-example
#
# For example:
#
# <form>
#   <div class="form-group">
#     <label for="exampleInputEmail1">Email address</label>
#     <input type="email" class="form-control" id="exampleInputEmail1" placeholder="Enter email">
#   </div>
#   <div class="form-group">
#     <label for="exampleInputPassword1">Password</label>
#     <input type="password" class="form-control" id="exampleInputPassword1" placeholder="Password">
#   </div>
#   <div class="form-group">
#     <label for="exampleInputFile">File input</label>
#     <input type="file" id="exampleInputFile">
#     <p class="help-block">Example block-level help text here.</p>
#   </div>
#   <div class="checkbox">
#     <label>
#       <input type="checkbox"> Check me out
#     </label>
#   </div>
#   <button type="submit" class="btn btn-default">Submit</button>
# </form>
#

module Formy
  class SimpleForm < BaseForm
    class Row < BaseForm::Row
      def close
        if @input && @input =~ /type=.checkbox./
          puts_push '<div class="checkbox">'
            puts_push '<label>'
              puts @input
              puts @label
              if @info
                puts '<span class="help-block">%s</span>' % @info
              end
            puts_pop '</label>'
          puts_pop '</div>'
        else
          if @label.is_a? Array
            @label, @label_for = @label
          end
          html = []
          if @label
            html << '<label for="%s">%s</label>' % [@label_for, @label]
          end
          html << @input
          if @info
            html << '<span class="help-block">%s</span>' % @info
          end
          puts_push '<div class="form-group">'
          puts html
          puts_pop '</div>'
        end
        super
      end
    end

    sub_element Row

    def buttons
      row { yield self }
    end

    def close
      @elements.each {|e| raw_puts e}
      if @buttons
        puts_push '<div class="buttons">'
          @buttons.each do |button|
            puts button
          end
        puts_pop '</div>'
      end
      puts_pop "</fieldset>"
      super
    end
  end
end
