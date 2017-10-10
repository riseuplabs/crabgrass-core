class Page::TagDowncaseParser < ActsAsTaggableOn::GenericParser
  def parse
    ActsAsTaggableOn::TagList.new.tap do |tag_list|
       tag_list.add @tag_list.split(',').map(&:strip).map(&:downcase).reject(&:empty?)
    end
  end
end
