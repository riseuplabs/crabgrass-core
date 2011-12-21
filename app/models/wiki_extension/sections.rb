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

    def set_body_for_section(section, text)
      updated_body = structure.update_body(section, text)
      self.body = updated_body
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
  end
end

