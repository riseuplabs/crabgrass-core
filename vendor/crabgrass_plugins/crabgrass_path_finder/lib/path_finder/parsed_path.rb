#=PathFinder::ParsedPath
# A simple class for parsing and generating 'readable url query paths'
#
# Given a path string like so:
#
#   /unread/tag/urgent/person/23/starred
#
# The corresponding ParsedPath would be an array that looks like this:
#
#  [ ['unread'], ['tag','urgent'], ['person',23], ['starred'] ]
#
# To create a ParsedPath, we identify the key words and their arguments, and split
# up that path into an array where each element is a different keyword (with its
# included arguments).
#
# This class has grown over time. It would have been much cleaner to implement
# as a hash.
# 
#:include:FILTERS
module PathFinder
class ParsedPath < Array

  ##
  ## CLASS METHODS
  ##

  def self.parse(path)
    if path.is_a?(ParsedPath)
      path
    elsif path.instance_of?(Array) and path.size == 1 and path[0].is_a?(Hash)
      # i am not sure where this is used
      ParsedPath.new(path[0])
    else
      ParsedPath.new(path)
    end
  end

  ##
  ## CONSTRUCTOR
  ##

  # constructs a ParsedPath from a path string, array, or hash
  #
  # Examples:
  #  string --  /unread/tag/urgent --> [['unread'],['tag','urgent']]
  #  array  --  ['person','23','starred'] --> [['person','23'],['starred']]
  #  hash   --  {"month"=>"6", "pending"=>"true"} --> [['month','6'],['pending']]
  #
  # the hash form is used to generate a path from the params from a search form.
  #
  def initialize(path=nil)
    return unless path
    @unparsable = []
    @last = nil
    if path.is_a? String or path.is_a? Array
      path = path.split('/') if path.instance_of? String
      new_from_array(path)
    elsif path.is_a? Hash
      new_from_hash(path)
    end
    # special post processing for some keywords
    self.each do |element|
      if element[0] == 'type'
        element[1].sub!('+', ' ') # trick CGI.escape to encode '+' as '+'.
      end
    end
    if @last == 'rss' and @unparsable.include?('rss')
      @format = last.to_s
    end
    return self
  end

  ##
  ## CONVERSION
  ##

  #
  # converts a parsed path to a string, suitable for a url.
  #
  def to_path
    '/' + self.flatten.collect{|i|CGI.escape i}.join('/') + (@format || '')
  end
  alias_method :to_s, :to_path     # manual string conversion
  alias_method :to_str, :to_path   # automatic string conversion

  # skip the cgi escaping
  def to_raw_path
    '/' + self.flatten.join('/') + (@format || '')
  end

  #  HASH_PATH_SEGMENT_DIVIDER = '.'
  #  ENCODED_DIVIDER = '%' + HASH_PATH_SEGMENT_DIVIDER[0].to_s(16)
  #  # path used for the window.location.hash
  #  # [['public'],['created_by','blue']] --> /public/created_by.blue/
  #  def to_hash_path
  #    path = collect{|segment| 
  #      segment.collect{|part|
  #        CGI.escape(part).
  #        gsub(HASH_PATH_SEGMENT_DIVIDER, ENCODED_DIVIDER)
  #      }.join(HASH_PATH_SEGMENT_DIVIDER)
  #    }.join("/")
  #    unless path.empty?
  #      return "/#{path}/"
  #    else
  #      return ""
  #    end
  #  end

  def to_param
    self.flatten + (@format ? [@format] : [])
  end
  def join(char=nil)
    to_param.join(char)
  end

  #
  # generates a string useful for display in the page title
  #
  def title
    self.collect{|segment| segment.join(' ')}.join(' > ')
  end

  ##
  ## PUBLIC ACCESS METHODS
  ##

  # returns an array of SearchFilter objects that correspond to the path, loaded
  # with the arguments contained in this ParsedPath.
  def filters
    @filters ||= self.collect do |segment|
      keyword = segment[0]
      args = segment[1..-1]
      search_filter = SearchFilter[keyword]
      [search_filter, args]
    end
  end

  # return true if keyword is in the path
  def keyword?(word)
    detect{|e| e[0] == word}
  end

  # returns a parsed path for one segment in the path
  def segment(word)
    ParsedPath.new(detect{|e| e[0] == word})
  end

  # returns the first argument of the pathkeyword
  # if:   path = "/person/23"
  # then: first_arg_for('person') == 23
  def first_arg_for(word)
    element = keyword?(word)
    return nil unless element
    return element[1]
  end
  alias :arg_for :first_arg_for

  # returns first argument of the keyword as an Integer
  # or 0 if the argument is not set
  def int_for(word)
    (arg_for(word)||0).to_i
  end

  # returns all the arguments for the keyword, as an array
  def args_for(keyword)
    segment = detect{|e| e[0] == keyword}
    if segment and segment.length > 1
      segment[1..-1]
    else
      []
    end
  end

  # assuming this parsed path contains just one keyword, this returns the
  # args for it.
  #def args()
  #  args_for(first[0])
  #end

  # returns the search text, if any
  # ie returns "glorious revolution" if path == "/text/glorious+revolution"
  def search_text
    element = keyword? 'text'
    return nil unless element
    return element[1].gsub('+', ' ')
  end

  # returns true if arg is the value for a sort keyword
  # ie sort_arg('created_at') is true if path == /ascending/created_at
  def sort_arg?(arg=nil)
    if arg
      (keyword?('ascending') and first_arg_for('ascending') == arg) or (keyword?('descending') and first_arg_for('descending') == arg)
    else
      keyword?('ascending') or keyword?('descending')
    end
  end

  def sort_by_time?
    sort_arg?('created_at') or sort_arg?('updated_at')
  end


  ##
  ## SETTERS
  ##

  def remove_sort
    self.delete_if{|e| e[0] == 'ascending' or e[0] == 'descending' }
  end

  # adds the sort field, but only if there is none set yet.
  def default_sort(field, direction='descending')
    unless sort_arg?
      self << [direction, field]
    end
    self
  end

  # merge two parsed paths together.
  # for duplicate keywords use the ones in the path_b arg
  def merge(path_b)
    path_b = ParsedPath.parse(path_b)
    if path_b.first == ['all']
      return ParsedPath.new([])
    end
    path_a = self.dup
    path_a.remove_sort if path_b.sort_arg?
    path_a.replace((path_a + path_b).uniq)
  end

  # same as merge, but replaces self.
  def merge!(path_b)
    path_b = ParsedPath.parse(path_b)
    if path_b.first == ['all']
      return self.replace(ParsedPath.new([]))
    end
    self.remove_sort if path_b.sort_arg?
    self.concat(path_b).uniq!
    self
  end

  # removes the path elements in path_b from self, returns a copy
  def remove(path_b)
    path_b = ParsedPath.parse(path_b)
    if path_b.first == ['all']
      return ParsedPath.new([])
    end
    keywords = path_b.keywords
    self.select do |segment|
      unless keywords.include?(segment[0])
        segment
      end
    end
  end

  # removes the path elements in path_b from self
  def remove!(path_b)
    self.replace(remove(path_b))
  end

  # replace one keyword with another.
  def replace_keyword(keyword, newkeyword, arg1=nil, arg2=nil)
    ParsedPath.new.replace(collect{|elem|
      if elem[0] == keyword
        [newkeyword,arg1,arg2].compact
      else
        elem
      end
    })
  end

  #
  # uniq()
  # ensures there are no search filters duplicates for search filters
  # defined as singletons. later segments take priority over earlier segments.
  # the path returned is reordered based on the search filter path_order settings.
  #
  def uniq()
    seen = {}
    new_path = ParsedPath.new([])
    reverse.each do |segment|
      keyword = segment.first
      if SearchFilter[keyword].singleton?
        unless seen[keyword]
          new_path << segment
          seen[keyword] = true
        end
      else
        new_path << segment
      end
    end
    new_path.sort_by_order
  end

  def uniq!()
    self.replace(self.uniq)
  end

  def sort_by_order
    self.sort {|a,b| path_order(a[0]) <=> path_order(b[0])}
  end

  # sets the value of the keyword in the parsed path,
  # replacing existing value or adding to the path as necessary.
  def set_keyword(keyword, arg1=nil, arg2=nil)
    if keyword?(keyword)
      replace_keyword(keyword,keyword,arg1,arg2)
    else
      self << [keyword,arg1,arg2].compact
    end
  end

  # returns a new path with the specified format.
  # if arg is nil, just returns the current format.
  def format(format_type=nil)
    if format_type.nil?
      @format
    else
      path = self.dup
      path.format = format_type
      path
    end
  end
  def format=(value)
    @format = value.to_s
  end

  ##
  ## PRIVATE METHODS
  ##

  protected

  # returns an array of just the keywords
  def keywords
    self.collect {|segment| segment[0] }
  end

  private

  def path_order(keyword)
   SearchFilter[keyword].try(:path_order) || 10000
  end

  def new_from_array(path)
    @last = path.last
    pathqueue = path.reverse
    while keyword = pathqueue.pop
      search_filter = SearchFilter[keyword]
      if search_filter
        element = [keyword]
        search_filter.path_argument_count.times do |i|
          element << pathqueue.pop if pathqueue.any?
        end
        self << element
      else
        @unparsable << keyword
      end
    end
  end

  def new_from_hash(path)
    path = path.sort_by_order
    path.each do |key,value|
      next unless value.any?
      keyword = key.to_s
      search_filter = SearchFilter[keyword]
      if search_filter
        #if keyword == 'page_state' and value.any? # handle special pseudo keyword...
        #  self << [value.to_s]
        arg_count =  search_filter.path_argument_count
        if arg_count == 0
          self << [keyword]
        elsif arg_count == 1
          self << [keyword, value.to_s]
        elsif arg_count == 2
          self << [keyword, value[0].to_s, value[1].to_s]
        end
      else
        @unparsable << keyword
      end
    end
  end

end
end
