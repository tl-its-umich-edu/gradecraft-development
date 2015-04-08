class AssignmentFile < ActiveRecord::Base
  include S3File

  attr_accessible :file, :filename, :filepath, :assignment_id

  belongs_to :assignment

  validates :filename, presence: true, length: { maximum: 50 }

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  def course
    assignment.course
  end
end
