module SphinxTestHelper
  def print_sphinx_hints
    # cg:update_page_terms
      print_test_msg(:sphinx, "To make thinking_sphinx tests not skip, try this:
  bundle exec rake db:schema:dump cg:test:update_fixtures
  bundle exec rake RAILS_ENV=test db:test:prepare db:fixtures:load ts:rebuild")
  end

  def sphinx_working?(test_name="")
    if !ThinkingSphinx.sphinx_running?
      putc 'S'
      print_sphinx_hints
      false
    else
      true
    end
  end
end
