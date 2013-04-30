class ConvertMessagePageToDiscussionMessage < ActiveRecord::Migration
  # MessagePage class has been deleted a while ago,
  # define it with :: to make it top namespace
  class ::MessagePage < ::Page
  end

  #
  # There's a Page Observer trying to delete page notices now
  # for all pages destroyed. Rescue us if the table does not exist yet.
  #
  class ::PageObserver
    def after_destroy_with_rescue(page)
      after_destroy_without_rescue(page)
    rescue Mysql2::Error => e
      raise e unless e.to_s.include? "notices"
    end

    alias_method_chain :after_destroy, :rescue
  end

  def self.up

    # first we turn all the Message Pages with more or less than
    # two participants into Discussion Pages.

    puts "#{MessagePage.count} Message pages."
    puts "Converting to DiscussionPages."
    MessagePage.update_all { type: "DiscussionPage"},
      <<-EOSQL
        pages.id IN (
          SELECT page_id FROM user_participations
            GROUP BY page_id HAVING count(page_id) <> 2
        )
      EOSQL

    pages = MessagePage.all
    puts "#{pages.count} Message pages left."
    puts "Converting to Messages."
    pages.each do |page|
      turn_page_into_messages(page)
      page.destroy
    end
  ensure
    enable_timestamps
  end

  def self.turn_page_into_messages(page)
    page.discussion.try.posts.each do |post|
      text = post.body
      sender = post.user
      receiver = page.users.detect {|u| u != sender}

      return if sender.blank? || receiver.blank? || text.blank?

      # create the new message
      new_post = sender.send_message_to!(receiver, text)

      disable_timestamps
      new_post.update_attributes({:updated_at => post.updated_at, :created_at => post.created_at})
      enable_timestamps
    end
  end


  def self.down
  end

  protected

  def self.disable_timestamps
    PrivatePost.record_timestamps = false
    Post.record_timestamps = false
  end

  def self.enable_timestamps
    PrivatePost.record_timestamps = true
    Post.record_timestamps = true
  end

end
