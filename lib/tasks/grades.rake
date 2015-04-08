namespace :grades do

  desc "Set all grades that have a status as being instructor_modified"

  task :update_instructor_modified => :environment do
    puts "Setting grades as 'instructor_modified where a status exists..."
    total_updated = Grade.where("status is not null").update_all(instructor_modified: true)
    puts "Updated #{total_updated} grades with instructor_modified: true"
    puts "DONE"
  end

end
