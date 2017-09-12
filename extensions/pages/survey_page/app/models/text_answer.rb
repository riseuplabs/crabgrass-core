class TextAnswer < SurveyAnswer
  validate :value_fits_regexp

  def value_fits_regexp
    if regex.present? && value !~ Regexp.new(regex)
      errors.add(:value, "doesn't match /#{regex}/")
    end
  end

  def regex
    question.regex
  end
end
