module Crabgrass::Page
  module Data
    extend ActiveSupport::Concern

    module ClassMethods
      # Use page_terms to find what objects the user has access to. Note that it is
      # necessary to match against both access_ids and tags, since the index only
      # works if both fields are included.
      def visible_to(*args)
        access_filter = Page::Terms.access_filter_for(*args)
        access_filter_sql = <<-EOSQL
          MATCH(page_terms.access_ids, page_terms.tags)
          AGAINST (? IN BOOLEAN MODE)
        EOSQL
        select("#{table_name}.*")
          .joins(:page_terms)
          .where access_filter_sql, access_filter
      end

      def most_recent
        order 'updated_at DESC'
      end

      def exclude_ids(ids)
        if ids.any? and ids.is_a? Array
          { conditions: ["#{table_name}.id NOT IN (?)", ids] }
        else
          {}
        end
      end
    end

    included do
      # ruby has unexpected syntax for checking if Page is a superclass
      unless self <= ::Page
        has_many :pages, as: :data
        belongs_to :page_terms,
                   class_name: 'Page::Terms'
        def page
          pages.first
        end
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
      if page_terms.nil?
        self.page_terms = page.page_terms if page
      end
    end
  end
end
