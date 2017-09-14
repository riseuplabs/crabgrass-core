module User::Participation::History
  def start_watching?
    watch_changed? && watch == true
  end

  def stop_watching?
    watch_changed? && watch != true
  end

  def star_added?
    star_changed? && star == true
  end

  def star_removed?
    star_changed? && star != true
  end

  def cleared_user_access?
    access_changed? && access_sym.nil?
  end
end
