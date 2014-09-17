class AssignmentGroup < ActiveRecord::Base

  attr_accessible :assignment, :assignment_id, :group, :group_id

  belongs_to :assignment
  belongs_to :group

  #validates_presence_of :assignment_id
  #validates_presence_of :group_id, presence: true
  
  validates_uniqueness_of :assignment_id, { :scope => :group_id }

end