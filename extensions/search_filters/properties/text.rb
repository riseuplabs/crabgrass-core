SearchFilter.new('/text/:text/') do
  #
  # This is a pretty useless search condition, and exists only
  # in cases where sphinx is not available.
  #
  mysql do |query, text|
    query.add_sql_condition(
      'pages.title LIKE ?',
      "%#{text}%"
    )
  end

  #
  # sphinx should normally be used for all text queries:
  #
  sphinx do |query, text|
    query.add_text_filter(text)
  end

  #
  # ui
  #

  self.path_order = 100
  self.singleton = true

  label do |opts|
    text = opts[:text]
    if text.length > 15
      "#{:search.t}: #{h(text[0..14])}..."
    else
      "#{:search.t}: #{h(text)}"
    end
  end
end
