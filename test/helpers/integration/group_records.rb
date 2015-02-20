module GroupRecords

  def group
    records[:group] ||= FactoryGirl.create(:group)
  end

  def public_group_to_pester
    records[:public_group_to_pester] ||= FactoryGirl.create(:group).tap do |pester|
      pester.grant_access! public: [:view, :pester]
    end
  end

  def group_to_pester
    records[:group_to_pester] ||= FactoryGirl.create(:group).tap do |pester|
      pester.grant_access! public: :pester
    end
  end

  def public_group
    records[:public_group] ||= FactoryGirl.create(:group).tap do |hide|
      hide.grant_access! public: :view
    end
  end

end
