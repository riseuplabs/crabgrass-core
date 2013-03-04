class TextAnswer < SurveyAnswer

  validate :value_fits_regexp

  def value_fits_regexp
    if self.regex.present? && !(self.value =~ Regexp.new(self.regex))
      errors.add(:value, "doesn't match /#{self.regex}/")
    end
  end
  def regex ; self.question.regex ; end
end
