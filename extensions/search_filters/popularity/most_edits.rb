SearchFilter.new('/most-active-in/:time/:unit/') do

  #
  # only works with mysql queries
  #
  mysql do |query, time, unit|
    query.add_most_condition("edits", time, unit)
  end

  #
  # ui
  #

  self.singleton = true
  self.section = :popular_pages
  self.exclude = :popular_pages

  self.description = "pages that have had the most contributions"
  html(:submit_button => false) do
    content_tag(:p) do
      [ filter_submit_button(:date_today.t, {:time => 24, :unit=>'hours'}),
        filter_submit_button(:date_this_week.t, {:time => 7, :unit=>'days'}),
        filter_submit_button(:date_this_month.t, {:time => 30, :unit=>'days'}),
        filter_submit_button(:date_this_year.t, {:time => 1, :unit=>'years'})
      ].join(' ')
    end 
  end

  label do |opts|
    if opts[:time]
      :most_active.t
    else
      :most_active.t + '...'
    end
  end

end

