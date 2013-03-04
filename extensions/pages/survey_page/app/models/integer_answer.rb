class IntegerAnswer < SurveyAnswer

  validate :value_above_minimun
  validate :value_below_maximum


  def value_above_minimum
    if(self.minimum.present? && self.minimum > self.value)
      errors.add(:value, "must be greater than #{self.minimum}")
    end
  end

  def value_below_maximum
    if(self.maximum.present? && self.maximum < self.value)
      errors.add(:value, "must be smaller than #{self.maximum}")
    end
  end

  def self.minimum ; self.question.minimum ; end
  def self.maximum ; self.question.maximum ; end
  def value ; read_attribute(:value).to_i ; end
  def value=(v) write_attribute(:value, v.to_i) ; end
end
