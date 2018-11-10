#
# ECOLOGY tasks
#
# Removing data that has become stale.
#
# In order to avoid accumulating more and more outdated data over time
# we remove data after it has not been accessed for a while.
#

namespace :cg do
  namespace :ecology do
    desc 'Run all ecology tasks'
    task all: [
      :empty_old_trash
    ]

    desc 'Remove Pages from the trash that have been there for a year'
    task(empty_old_trash: :environment) do
      old_trash = Page.where("updated_at < ?", 1.year.ago).where(flow: 3)
      puts "Removing #{old_trash.count} pages from the trash"
      old_trash.find_each.with_index do |page, i|
        page.destroy
        print "#{i}\r"
      end
      puts "Done."
    end
  end
end
