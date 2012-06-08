=begin

 WikiController

 This is the controller for the in-place wiki editor, not for the
 the wiki page type (wiki_page_controller.rb).

=end
module Common::Wiki

  def self.included(base)
    base.class_eval do
      #will we need a context for page wikis?
      before_filter :fetch_context # needs to be defined in the controller itself
#      before_filter :fetch_wiki, :only => [:show, :edit, :update]
#      before_filter :setup_wiki_rendering

      stylesheet 'wiki_edit'

      helper 'wikis/sections'
    end
  end

  def show
    render :template => '/common/wiki/show', :locals => {:preview => params['preview']}
  end

  protected

  # I'm not sure we still need this. I wonder if we could include it in the
  # wiki model as we know the context from the wikis profile / page owner.
#  def setup_wiki_rendering
#    return unless @wiki
#    @wiki.render_body_html_proc {|body| render_wiki_html(body, @group.name)}
#  end
end
