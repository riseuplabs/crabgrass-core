#
# this is taken from acts_as_taggable_on_steriods
#
# View:
#
#  <% tag_cloud(@tags, :classes => %w(tag1 tag2 tag3 tag4)) do |tag, css_class| %>
#    <%= link_to tag.name, { :action => :tag, :id => tag.name }, :class => css_class %>
#  <% end %>
#
# alternately:
# 
#  <%= tag_cloud(tags) {|tag, klass| link_to(...) }.join(', ') %>
#
# CSS:
#
#  .tag1 { font-size: 1.0em; }
#  .tag2 { font-size: 1.2em; }
#  .tag3 { font-size: 1.4em; }
#  .tag4 { font-size: 1.6em; }
#

module Ui::TaggingHelper

  def tag_cloud(tags, options={})
    options = {:classes => ['tag1','tag2','tag3','tag4'], :max => false}.merge(options)
    return if tags.empty?
    max_count = tags.sort_by(&:count).last.count.to_f
    if options[:max]
      if tags.size >= options[:max]
        max_list_count = tags.sort_by(&:count)[0-options[:max_list]].count
      elsif tags.size < options[:max]
        max_list_count = tags.sort_by(&:count)[0].count
      end
    end

    tag_count = 0
    tags.collect do |tag|
      next if options[:max] and (tag.count < max_list_count || (tag.count == max_list_count && tag_count >= options[:max]))
      tag_count += 1
      if max_count > 0
        index = ((tag.count / max_count) * (options[:classes].size - 1)).round
      else
        index = 0
      end
      yield tag, options[:classes][index]
    end
  end


  def tag_link(tag, owner, css_class='tag2')
    name = CGI.escape tag.name
    if owner.try.name and owner.is_a? Group
      link_path = "/groups/tags/#{owner.name}/#{name}"
    else
      link_path = "/me/search/tag/#{name}"
    end
    link_to h(tag.name), link_path, :class => css_class
  end

end
