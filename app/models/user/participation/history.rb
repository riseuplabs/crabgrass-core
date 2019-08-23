module User::Participation::History
  def start_watching?
    saved_change_to_watch? && watch == true
  end

  def stop_watching?
    saved_change_to_watch? && watch != true
  end

  def star_added?
    saved_change_to_star? && star == true
  end

  def star_removed?
    saved_change_to_star? && star != true
  end

  def cleared_user_access?
    saved_change_to_access? && access_sym.nil?
  end
end
