##
## Handy tools for debugging.
## see doc/DEBUGGING for more info.
##

# set envirenment variable SHOWLOGS to log sql commands to stdout.
if ENV['SHOWLOGS'].present?
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

# here is a handy method for dev mode. it dumps a table to a yml file.
# you can use it to build up your fixtures. dumps to
# test/fixtures/dumped_tablename.yml
def export_yml(table_name)
  sql  = "SELECT * FROM %s"
  i = "000"
  File.open("#{RAILS_ROOT}/test/fixtures/dumped_#{table_name}.yml", 'w') do |file|
    data = ActiveRecord::Base.connection.select_all(sql % table_name)
    file.write data.inject({}) { |hash, record|
      hash["#{table_name}_#{i.succ!}"] = record
      hash
    }.to_yaml
  end
end

#
# have you ever wanted to know what part of your code was triggering a particular
# sql query? set the STOP_ON_SQL environment variable to find out.
#
# For example:
#
# export STOP_ON_SQL='SELECT * FROM `users` WHERE (`users`.`id` = 633)'
# script/server
#

if ENV['STOP_ON_SQL'].present?
  STOP_ON_SQL_MATCH = Regexp.escape(ENV['STOP_ON_SQL']).gsub(/\\\s+/, '\s+')
  class ActiveRecord::ConnectionAdapters::AbstractAdapter
    def log_with_debug(sql, name, &block)
      if sql.match(STOP_ON_SQL_MATCH)
        debugger
        true
      end
      log_without_debug(sql, name, &block)
    end
    alias_method_chain :log, :debug
  end
end

#
# Debugging activerecord callbacks.
#

if ENV['DEBUG_CALLBACKS'].present?
  #
  # if enabled, this will print out when each callback gets called.
  #
  class ActiveSupport::Callbacks::Callback
    @@last_kind = nil

    @@debug_callbacks = [:before_validation, :before_validation_on_create, :after_validation,
   :after_validation_on_create, :before_save, :before_create, :after_create, :after_save]

    @@active_record_callbacks = nil

    def call_with_debug(*args, &block)
      @@active_record_callbacks ||= Hash[@@debug_callbacks.collect do |callback|
        methods = ActiveRecord::Base.send("#{callback}_callback_chain").collect{|cb|cb.method}
        [callback, methods]
      end]

      if should_run_callback?(*args) and method.is_a?(Symbol) and @@debug_callbacks.include?(kind) and !@@active_record_callbacks[kind].include?(method)
        if @@last_kind != kind
          puts "++++ #{kind} #{'+'*60}"
        end
        puts "---- #{method} ----"
        @@last_kind = kind
      end
      call_without_debug(*args, &block)
    end
    alias_method_chain :call, :debug
  end

  # this is most useful in combination with ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end


