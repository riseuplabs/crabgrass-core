namespace :cg do
  namespace :upgrade do
    desc 'Turn the Rating records for posts into Star records'
    task(migrate_ratings_to_stars: :environment) do
      old_count = Star.count
      Star.connection.execute <<-EOSQL
      INSERT INTO stars
        (`created_at`, `starred_type`, `starred_id`, `user_id`)
      SELECT created_at, rateable_type, rateable_id, user_id
      FROM ratings
      WHERE ratings.rateable_type = 'Post'
      EOSQL
      if Star.count == old_count + Rating.where(rateable_type: 'Post').count
        puts "Converted #{Star.count - old_count} Ratings to Stars."
        Rating.where(rateable_type: 'Post').delete_all
      end
    end

    desc 'Reset star counters to match the actual number of stars'
    task(reset_star_counters: :environment) do
      deleted = 0
      updated = 0
      Star.where(starred_type: 'Post').pluck(:starred_id).uniq.each do |starred|
        begin
          Post.reset_counters(starred, :stars)
          updated += 1
        rescue ActiveRecord::RecordNotFound
          deleted += Star.where(starred_type: 'Post', starred_id: starred).delete_all
        end
      end
      puts "Reset #{updated} stars_counters and deleted #{deleted} dangling stars."
    end
  end
end
