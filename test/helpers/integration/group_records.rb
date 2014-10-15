module GroupRecords

  def group
    records[:group] ||= FactoryGirl.create(:group)
  end

  def group_to_pester
    records[:group_to_pester] ||= FactoryGirl.create(:group).tap do |pester|
      pester.grant_access! public: :pester
    end
  end

  def hidden_group
    records[:hidden_group] ||= FactoryGirl.create(:group).tap do |hide|
      hide.revoke_access! public: :view
    end
  end

end
