module Crabgrass::Page
  module Data
    extend ActiveSupport::Concern

    included do
      # Use page_terms to find what objects the user has access to. Note that it is
      # necessary to match against both access_ids and tags, since the index only
      # works if both fields are included.
      scope :visible_to, lambda { |*args|
        access_filter = Page::Terms.access_filter_for(*args)
        { select: "#{table_name}.*", joins: :page_terms,
          conditions: ['MATCH(page_terms.access_ids,page_terms.tags) AGAINST (? IN BOOLEAN MODE)', access_filter]
        }
      }

      scope :most_recent, order: 'updated_at DESC'

      scope :exclude_ids, lambda {|ids|
        if ids.any? and ids.is_a? Array
          {conditions: ["#{table_name}.id NOT IN (?)", ids]}
        else
          {}
        end
      }

      # ruby has unexpected syntax for checking if Page is a superclass
      unless self <= ::Page
        has_many :pages, as: :data
        belongs_to :page_terms,
          class_name: 'Page::Terms'
        def page; pages.first; end
      else
        # I do not think this is used, or would be very useful:
        #base.class_eval do
        #  def page; self; end
        #end
      end

      before_save :ensure_page_terms
    end

    public

    # allows user.may?(:view, asset)
    def visible?(user)
      page_terms.access_ids_include?(user)
    end

    protected

    def ensure_page_terms
      if self.page_terms.nil?
        self.page_terms = self.page.page_terms if self.page
      end
    end

  end
end
