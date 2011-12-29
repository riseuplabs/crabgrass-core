module WikiExtension
  module Sections

    class SectionNotFoundError < ArgumentError
      def initialize(section = 'document', options = {})
        message = :cant_find_wiki_section.t(:section => section)
        super(message)
      end
    end

    class OtherSectionLockedError
      def initialize(section, options = {})
        message = :other_section_locked_error.t :section => section
        super(message, options)
      end
    end

    def all_sections
      structure.all_sections
    end

    def save_section!(section, text)
      section = structure.find_section(section) unless section.is_a? GreenTree
      parent = section.parent
      index = parent.index(section)
      updated_body = section.sub_markup(text)
      self.body = updated_body
      self.save!
      parent = structure.find_section(parent.name || :document)
      parent[index].name
    end

    def get_body_for_section(section)
      structure.get_body(section)
    end

    def level_for_section(section)
      structure.get_level(section)
    end

    def successor_for_section(section)
      structure.get_successor(section)
    end

    def get_body_html_for_section(section)
      GreenCloth.new(get_body_for_section(section), link_context, [:outline]).to_html
    end
  end
end

