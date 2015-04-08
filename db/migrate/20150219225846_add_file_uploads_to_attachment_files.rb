class AddFileUploadsToAttachmentFiles < ActiveRecord::Migration
  def change
    [:assignment_files, :badge_files, :challenge_files, :grade_files, :submission_files].each do |table|
      change_table table do |t|
        t.string :file
        t.boolean :file_processing, null: false, default: false
        t.timestamps
      end
    end
  end
end
