namespace :teams do
  desc "Calculate team ranks from the last 24 hours"
 	task :update_team_rank => :environment do
    Team.update_ranks
  end
end
