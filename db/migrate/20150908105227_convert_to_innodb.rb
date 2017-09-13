class ConvertToInnodb < ActiveRecord::Migration
  #
  # InnoDB allows us to perform non blocking backups with transactions.
  #
  # So we convert all the tables that remained as MyISAM tables to
  # InnoDB except page_terms which need the full text search capacities
  # that InnoDB only gained with mysql 5.6. (we're still on 5.5).
  #
  # trackings were actively using "INSERT DELAYED" which also is
  # MyISAM specific - but will be removed in this commit as well.
  #
  # The other tables just happen to still be MyISAM in production
  # because it used to be the default.
  #
  def self.up
    execute('ALTER TABLE trackings ENGINE=InnoDB')
    execute('ALTER TABLE migrations_info ENGINE=InnoDB')
    execute('ALTER TABLE schema_migrations ENGINE=InnoDB')
    if ActiveRecord::Base.connection.table_exists? 'plugin_schema_info'
      execute('ALTER TABLE plugin_schema_info ENGINE=InnoDB')
    end
  end

  def self.down
    execute('ALTER TABLE trackings ENGINE=MyISAM')
  end
end
