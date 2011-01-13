SearchFilter.new('/most-views-in/:time/:unit/') do

  #
  # only works with mysql queries
  #
  mysql do |query, time, unit|
    query.add_most_condition("views", time, unit)
  end

  #
  # ui
  #

  self.singleton = true
  self.section = :popular_pages
  self.label = :most_viewed

  self.description = "pages that have been viewed the most"
  html do
    @filter_submit_button = false
    content_tag(:p) do
      [ filter_submit_button(:date_today.t, {:time => 24, :unit=>'hours'}),
        filter_submit_button(:date_this_week.t, {:time => 7, :unit=>'days'}),
        filter_submit_button(:date_this_month.t, {:time => 30, :unit=>'days'}),
        filter_submit_button(:date_this_year.t, {:time => 1, :unit=>'years'})
      ].join(' ')
    end 
  end

end

