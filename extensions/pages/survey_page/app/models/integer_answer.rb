class IntegerAnswer < SurveyAnswer
  validate :value_above_minimun
  validate :value_below_maximum

  def value_above_minimum
    if minimum.present? && minimum > value
      errors.add(:value, "must be greater than #{minimum}")
    end
  end

  def value_below_maximum
    if maximum.present? && maximum < value
      errors.add(:value, "must be smaller than #{maximum}")
    end
  end

  def self.minimum
    question.minimum
  end

  def self.maximum
    question.maximum
  end

  def value
    read_attribute(:value).to_i
  end

  def value=(v)
    write_attribute(:value, v.to_i)
  end
end
