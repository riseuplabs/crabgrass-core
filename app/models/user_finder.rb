class UserFinder

  VALID_QUERIES = ['friends', 'peers', 'search']

  def initialize(user)
    @user = user
  end

  def find_by_path(path, options = {})
    options.reverse_merge! default: :friends
    query, parts = query_from_path(path, options)
    self.send query, parts
  end

  def query_from_path(path, options)
    parts = path.try.split('/') || []
    query = parts.shift
    query = options[:default] unless VALID_QUERIES.include?(query)
    return query.to_sym, parts
  end

  protected

  def friends(ignored)
    @user.try.friends
  end

  def peers(ignored)
    @user.try.peers
  end

  def search(terms)
    if term = filter(terms)
      User.named_like(term).with_access(access)
    end
  end

  def filter(terms)
    term = terms.try.first
    if term.present?
      term.gsub('%', '\%').gsub('_', '\_') + '%'
    end
  end

  def access
    {(@user || :public) => :view}
  end
end
