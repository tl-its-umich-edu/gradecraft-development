namespace :teams do

  # Use this to test on development only -- it will assing a random grouping of
  # students in each team as gsis
  #
  desc "Set the first member of each team as a gsi (for testing in development)"
  task :development_db_create_leaders => :environment do
    raise "This task should only be run in development!" unless Rails.env == "development"
    Team.all.each do |team|
      leaders = []
      puts "Setting leaders of team #{team.name}"
      Random.new.rand(1..3).times do
        leader = team.students.order("RANDOM()").first

        if leader && !leaders.include?(leader.name)
          puts "  #{leader.name}"
          leaders << leader.name

          membership = leader.course_memberships.where(course: team.course).first
          membership.role = "gsi"
          membership.save
        end
      end
    end
  end

  # Before running `rake teams:transfer_leaderships` this method will display
  # all gsi's under the student listting with (gsi) after their names
  # after running the transfer, they should be listed as leaders, and not students
  #
  desc "Outputs a list of team leaders and students to the console"
  task :puts_memberships => :environment do
    team_member_list = Hash.new {|h, k| h[k] = {students: [], leaders: []} }
    Team.all.each do |team|
      team.leaders.each do |leader|
        team_member_list[team.name][:leaders] << leader.name
      end
      team.students.each do |student|
        if student.role(team.course) == "student"
          team_member_list[team.name][:students] << student.name
        else
          team_member_list[team.name][:students] << "#{student.name} (#{student.role(team.course)})"
        end
      end
    end
    team_member_list.each do |k,v|
      puts k
      puts "------------------------"
      puts "Leaders:"
      v[:leaders].each {|leader| puts "  #{leader}"}
      puts "Students:"
      v[:students].each {|student| puts "  #{student}"}
      puts ""
    end
  end

  # Use this rake task to create team leaders out of all team members who have a gsi role
  # for the course. They will also be removed from the team memberships
  #
  desc "Tranfer team leaders from team membership to team leadership"
  task :transfer_leaderships => :environment do
    Team.all.each do |team|
      team.students.each do |student|
        if student.role(team.course) == "gsi"
          leadership = TeamLeadership.new leader: student, team: team
          leadership.save
          student.team_memberships.where(team: team).first.destroy
          puts "transferred #{student.name} from student to leader for team \"#{team.name}\""
        end
      end
    end
  end
end
