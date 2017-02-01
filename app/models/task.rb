class Task < ActiveRecord::Base

  belongs_to :page
#  has_and_belongs_to_many :users, :foreign_key => 'task_id'
  has_many :participations,
    dependent: :destroy
  has_many :users, through: :participations
  acts_as_list scope: :page
  format_attribute :description
  validates_presence_of :name

  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  def self.completed
    where "completed_at IS NOT NULL"
  end

  def self.pending
    where completed_at: nil
  end

  before_create :set_user
  def set_user
    if self.created_by
      self.updated_by = self.created_by
    end
    true
  end

  def owner_name
    page.try.owner_name
  end

  def state=(state)
    self.complete if state == 'complete'
    self.pending if state == 'pending'
  end

  def complete
    self.completed_at = Time.now
  end

  def pending
    self.completed_at = nil
  end

  def completed
    completed_at != nil && completed_at < Time.now
  end
  alias :completed? :completed

  def past_due?
    !completed? && due_at && due_at.to_date < Date.today
  end
  alias :overdue? :past_due?

end
