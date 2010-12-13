# :include:path_finder/README
module PathFinder

  #  this works, but seems like overkill:
  #  "PathFind::#{sym.to_s.capitalize}::Options".split('::').inject(Object) {|x,y| x.const_get(y) }

  def self.get_options_module(sym)
    case sym
      when :mysql:      PathFinder::Mysql::Options
      when :postgres:   PathFinder::Postgres::Options
      when :sphinx:     PathFinder::Sphinx::Options
    end
  end

  def self.get_query(sym)
    case sym
      when :mysql:      PathFinder::Mysql::Query
      when :postgres:   PathFinder::Postgres::Query
      when :sphinx:     PathFinder::Sphinx::Query
    end
  end

  class Error < RuntimeError
  end

end

