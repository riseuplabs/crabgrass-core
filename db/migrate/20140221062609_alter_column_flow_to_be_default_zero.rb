#
# sphinx cannot filter on nil! so where we used to use nil for the 'normal' flow, now we use zero.
#
class AlterColumnFlowToBeDefaultZero < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE pages ALTER COLUMN flow SET DEFAULT 0;"
    execute "ALTER TABLE page_terms ALTER COLUMN flow SET DEFAULT 0;"
    execute "UPDATE pages SET flow = 0 WHERE flow IS NULL"
    execute "UPDATE page_terms SET flow = 0 WHERE flow IS NULL"
  end

  def self.down
    execute "ALTER TABLE pages ALTER COLUMN flow DROP DEFAULT;"
    execute "ALTER TABLE page_terms ALTER COLUMN flow DROP DEFAULT;"
    execute "UPDATE pages SET flow = NULL WHERE flow = 0"
    execute "UPDATE page_terms SET flow = NULL WHERE flow = 0"
  end
end
