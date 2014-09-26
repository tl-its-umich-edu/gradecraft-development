class Proposal < ActiveRecord::Base
  attr_accessible :title, :proposal, :approved

  belongs_to :group

  scope :order_by_creation_date, -> { order('created_at ASC') }
end
