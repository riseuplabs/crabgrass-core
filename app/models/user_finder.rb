class UserFinder

  # There can only be one scope per path.
  # The keys are the path parts that identify the scope
  # The values need to match methods that can be called on @user.
  PATH_SCOPES = {contacts: :friends, peers: :peers}

  # queries take a parameter and there could be multiple in a single path
  # These will be called as methods in the UserFinder.
  QUERIES = ['search']

  def initialize(user, path)
    @user = user
    @path = path
  end

  def find
    conditions.each do |method, args|
      self.send method, args
    end
    @search_results || find_without_search_term
  end

  def scope
    @scope ||= init_scope
  end

  def conditions
    @conditions ||= queries.presence || {}
  end

  def queries
    query = nil
      @path.split('/').inject(Hash.new) do |hash, part|
      if query.present?
        hash[query] = part
        query = nil
      else
        query = part if QUERIES.include?(part)
      end
      hash
    end
  end

  def query_term
    conditions.values.first
  end

  protected

  def init_scope
    if scope_method.present?
      scope = @user.public_send scope_method
    else
      User
    end
  end

  def scope_method
    @path.split('/').map{|part| PATH_SCOPES[part.to_sym]}.compact.first
  end

  def find_without_search_term
    if scope_method.present?
      scope.with_access(access)
    else 
      # do not list all users
      User.none
    end
  end

  def search(term)
    if term.present?
      @search_results = scope.with_access(access).named_like(filter(term))
    end
  end

  def filter(term)
    term.gsub('%', '\%').gsub('_', '\_') + '%'
  end

  def access
    {@user => :view}
  end
end
