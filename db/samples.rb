user_names = ['Ron Weasley','Fred Weasley','Harry Potter','Hermione Granger','Colin Creevey','Seamus Finnigan','Hannah Abbott','Pansy Parkinson','Zacharias Smith','Blaise Zabini', 'Draco Malfoy', 'Dean Thomas', 'Millicent Bulstrode', 'Terry Boot', 'Ernie Macmillan', 'Roland Abberlay', 'Katie Bell', 'Regulus Black', 'Euan Abercrombie', 'Brandon Angel', 'Jada Angela', 'Pete Balsall', 'Allison Barnes', 'Fiona Belmont', 'Kajol Bhatt', 'Sally Birchgrove', 'Stephen Challock', 'Dennis Creevey', 'Lisa Cullen', 'Winky Crocket', 'Fay Dunbar', 'Lily Evans', 'Rosalyn Ewhurst', 'Terrence Fogarty', 'Hamish Frater', 'Vicky Frobisher', 'Godric Gryffindor', 'Ryan Henry', 'David Hamblin', 'Kelly Harborne', 'Thelma Holmes', 'Geoffrey Hooper', 'Carl Hopkins', 'Satoru Lida', 'Nandini Johar', 'Angelina Johnson', 'Lee Jordan']

educ_team_names = ['Harm & Hammer', 'Abusement Park','Silver Woogidy Woogidy Woogidy Snakes','Carpe Ludus','Eduception','Operation Unthinkable','Team Wang','The Carpal Tunnel Crusaders','Pwn Depot']

educ_badge_names = ['Creative', 'Inner Eye', 'Patronus Producer','Cheerful Charmer','Invisiblity Cloak','Marauders Map','Lumos','Rune Reader','Tea Leaf Guru','Wizard Chess Grand Master','Green Thumb','Gamekeeper','Seeker','Alchemist','Healer','Parseltongue','House Cup']

polsci_badge_names = ['MINOR: Learning from Mistakes', 'MINOR: Learning from Mistakes', 'MINOR: Halloween Special', 'MINOR: Thanksgiving Special', 'MINOR: Now It is Personal', 'MAJOR: Makeup Much', 'MAJOR: Practice Makes Perfect', 'MAJOR: Combo Platter', 'MINOR: Makeup Some', 'MINOR: Participatory Democrat', 'MINOR: Number One', 'MINOR: Rockstar', 'MINOR: Over-achiever', 'MINOR: Avid Reader', 'MINOR: Nice Save!', 'MINOR: The Nightstalker', 'MINOR: Paragon of Virtue', 'MAJOR: Bad Investment', 'MINOR: Leader of the pack', 'MINOR: Thoughtful Contribution']

educ_grade_scheme_hash = { [0,600000] => 'F', [600000,649000] => 'D+', [650000,699999] => 'C-', [700000,749999] => 'C', [750000,799999] => 'C+', [800000,849999] => 'B-', [850000,899999] => 'B', [900000,949999] => 'B+', [950000,999999] => 'A-', [1000000,1244999] => 'A', [1245000,1600000] => 'A+'}

educ_grade_levels = ['Amoeba', 'Sponge', 'Roundworm', 'Jellyfish', 'Leech', 'Snail', 'Sea Slug', 'Fruit Fly', 'Lobster', 'Ant', 'Honey Bee', 'Cockroach', 'Frog', 'Mouse', 'Rat', 'Octopus', 'Cat', 'Chimpanzee', 'Elephant', 'Human', 'Orca']

information_grade_scheme_hash = { [0,600000] => 'E', [600000,629999] => 'D-', [630000,669999] => 'D', [670000,699999] => 'D+', [700000,729999] => 'C-', [730000,769999] => 'C', [770000,799999] => 'C+', [800000,829999] => 'B-', [830000,869999] => 'B', [870000,909999] => 'B+', [910000,949999] => 'A-', [950000,2200000] => 'A'}

information_grade_levels = ['Shannon', 'Weaver', 'Vannevar Bush', 'Turing', 'Boole', 'Gardner', 'Shestakov', 'Blackman', 'Bode', 'John Pierce', 'Thorpe', 'Renyi', 'Cohen', 'Berners Lee', 'Nash', 'Cailliau', 'Andreessen', 'Hartill', 'Ada Lovelace', 'Grace Hopper', 'Henrietta Leavitt', 'Anita Borg']

polsci_grade_scheme_hash = { [0,6000] => 'F', [6001,9000] => 'D-', [9001,12000] => 'D', [12001,16000] => 'D+', [16001,19000] => 'C-', [19001,22000] => 'C', [22001,26000] => 'C+', [26001,29000] => 'B-', [29001,32000] => 'B', [32001,36000] => 'B+', [36001,39000] => 'A-', [39001,48000] => 'A' }

polsci_grade_levels = ['Hammurabi', 'Confucius', 'Socrates', 'Cicero', 'William of Ockham', 'Mozi', 'Xenophon', 'Saint Augustine', 'Plato', 'Diogenes', 'Machiavelli', 'Aeschines', 'Ghazali', 'Martin Luther', 'Aristotle', 'Calvin', 'Maimonides', 'St. Thomas Aquinas', 'Xun Zi', 'Ibn Khaldun', 'Thiruvalluvar', 'Locke']

majors = ['Engineering','American Culture','Anthropology','Asian Studies','Astronomy','Cognitive Science','Creative Writing and Literature','English','German','Informatics','Linguistics','Physics']

courses = []

# Generate Videogames
courses << educ_course = Course.create! do |c|
  c.name = "Videogames & Learning"
  c.courseno = "EDUC222"
  c.year = Date.today.year
  c.semester = "Winter"
  c.max_group_size = 5
  c.min_group_size = 3
  c.team_setting = true
  c.teams_visible = true
  c.group_setting = true
  c.badge_setting = true
  c.shared_badges = true
  c.badges_value = false
  c.accepts_submissions = true
  c.predictor_setting = true
  c.tagline = "Games good, school bad. Why?"
  c.academic_history_visible = true
  c.media_file = "http://www.youtube.com/watch?v=LOiQUo9nUFM&feature=youtu.be"
  c.media_credit = "Albus Dumbledore"
  c.media_caption = "The Greatest Wizard Ever Known"
  c.office = "Room 4121 SEB"
  c.phone = "734-644-3674"
  c.class_email = "staff-educ222@umich.edu"
  c.twitter_handle = "barryfishman"
  c.twitter_hashtag = "EDUC222"
  c.location = "Whitney Auditorium, Room 1309 School of Education Building"
  c.office_hours = "Tuesdays, 1:30 pm – 3:30 pm"
  c.meeting_times = "Mondays and Wednesdays, 10:30 am – 12:00 noon"
  c.badge_term = "Achievement"
  c.user_term = "Learner"
  c.team_challenges = true
  c.grading_philosophy ="I believe a grading system should put the learner in control of their own destiny, promote autonomy, and reward effort and risk-taking. Whereas most grading systems start you off with 100% and then chips away at that “perfect grade” by averaging in each successive assignment, the grading system in this course starts everyone off at zero, and then gives you multiple ways to progress towards your goals. Different types of assignments are worth differing amounts of points. Some assignments are required of everyone, others are optional. Some assignments can only be done once, others can be repeated for more points. In most cases, the points you earn for an assignment are based on the quality of your work on that assignment. Do poor work, earn fewer points. Do high-quality work, earn more points. You decide what you want your grade to be. Learning in this class should be an active and engaged endeavor."
  c.media_file = "http://upload.wikimedia.org/wikipedia/commons/3/36/Michigan_Wolverines_Block_M.png"
end
puts "Videogames and Learning has been installed"

# Generate Political Theory
courses << polsci_course = Course.create! do |c|
  c.name = "Introduction to Political Theory"
  c.courseno = "POLSCI 101"
  c.year = Date.today.year
  c.semester = "Fall"
  c.max_group_size = 5
  c.min_group_size = 3
  c.team_setting = true
  c.teams_visible = false
  c.group_setting = true
  c.badge_setting = true
  c.shared_badges = true
  c.badges_value = true
  c.accepts_submissions = true
  c.predictor_setting = true
  c.academic_history_visible = true
  c.media_file = "http://www.youtube.com/watch?v=LOiQUo9nUFM&feature=youtu.be"
  c.media_credit = "Mika LaVaque Manty"
  c.office = "7640 Haven"
  c.phone = "734-644-3674"
  c.class_email = "staff-educ222@umich.edu"
  c.twitter_handle = "polsci101"
  c.twitter_hashtag = "polsci101"
  c.location = "1324 East Hall"
  c.office_hours = "1:30-2:30 Tuesdays, 2:00-3:00 Wednesdays"
  c.meeting_times = "MW 11:30-1"
  c.badge_term = "Power Up"
  c.team_challenges = false
  c.grading_philosophy = "Think of how video games work. This course works along the same logic. There are some things everyone will have to do to make progress. In this course, the readings, reading-related homework, lectures and discussion sections are those things.
But game play also allows you to choose some activities -- quests, tasks, challenges -- and skip others. You can partly make your own path through a game. So also in this course: the are some assignment types you may choose (because you are good at them, or because you like challenges) and others you can avoid (because your interests are elsewhere). You also have a choice on how you want to weight some of the optional components you choose!
In games, you start with a score of zero and 'level up' as you play. You might have to try some tasks several times before you get the points, but good games don't ever take your points away. Same here: everything you successfully do earns you more points.
In games, you sometimes earn 'trophies' or 'badges' or 'power-ups' as you play. They might not have been your primary goal, but you get them because you do something particularly well. In this course, you also can earn power-ups. 
And at the end of the term, your score is your grade."
  c.media_file = "http://upload.wikimedia.org/wikipedia/commons/3/36/Michigan_Wolverines_Block_M.png"
end
puts "Introduction to Political Theory has arrived"

# Generate Information Science
courses << information_course = Course.create! do |c|
  c.name = "Intro to Information Studies"
  c.courseno = "SI110"
  c.year = Date.today.year
  c.semester = "Fall"
  c.team_setting = true
  c.teams_visible = true
  c.group_setting = false
  c.badge_setting = false
  c.shared_badges = false
  c.badges_value = false
  c.accepts_submissions = true
  c.predictor_setting = true
  c.academic_history_visible = true
  c.media_file = "http://www.youtube.com/watch?v=LOiQUo9nUFM&feature=youtu.be"
  c.media_credit = "Cliff Lampe"
  c.phone = "777-777-7777"
  c.class_email = "staff-si110@umich.edu"
  c.twitter_handle = "si110"
  c.twitter_hashtag = "si101"
  c.location = "2245 North Quad"
  c.office_hours = "email me"
  c.meeting_times = "TTh 12:00-1:30"
  c.team_challenges = true
  c.grading_philosophy = "In this course, we accrue 'XP' which are points that you gain to get to different grade levels. If you can gather 950,000 XP, you will receive an A, not to mention the admiration of those around you. Because you’re in charge of figuring out how many XP you need to get the grade you want, there’s not really such a thing as a required assignment in this course. There are opportunities to gain XP, some of which are scheduled. Of course, you’ll need to do several Quests in order to get higher grade levels, and some Quests count for a ton of XP. Each of these quests is managed in GradeCraft, where you can see your progress, as well as check the forecasting tool to see what you need to do on future assignments to get your desired grade level. A quick note on our assessment philosophy. Most Quests will have rubrics attached, which will spell out our expectations. However, just meeting the details of the assignment is by definition average work, which would receive something around the B category. If your goal is to get an A, you will have to go above and beyond on some of these Quests."
  c.media_file = "http://upload.wikimedia.org/wikipedia/commons/3/36/Michigan_Wolverines_Block_M.png"
end
puts "Introduction to Information Science is in session"

educ_grade_scheme_hash.each do |range,letter|
  educ_course.grade_scheme_elements.create do |e|
    e.letter = letter
    e.level = educ_grade_levels.sample
    e.low_range = range.first
    e.high_range = range.last
  end
end
puts "Installed the EDUC 222 grading scheme. Roar!"


information_grade_scheme_hash.each do |range,letter|
  information_course.grade_scheme_elements.create do |e|
    e.letter = letter
    e.level = information_grade_levels.sample
    e.low_range = range.first
    e.high_range = range.last
  end
end
puts "Installed the Information grading scheme. Level up!"


polsci_grade_scheme_hash.each do |range,letter|
  polsci_course.grade_scheme_elements.create do |e|
    e.letter = letter
    e.level = polsci_grade_levels.shuffle.sample
    e.low_range = range.first
    e.high_range = range.last
  end
end
puts "Installed the Polsci grading scheme. Debate that!"


teams = educ_team_names.map do |team_name|
  educ_course.teams.create! do |t|
    t.name = team_name
  end
end
puts "The Team Competition has begun!"

# Generate sample students
students = user_names.map do |name|
  first_name, last_name = name.split(' ')
  username = name.parameterize.sub('-','.')
  User.create! do |u|
    u.username = username
    u.first_name = first_name
    u.last_name = last_name
    u.email = "#{username}@hogwarts.edu"
    u.password = 'uptonogood'
    u.courses << [ educ_course, polsci_course, information_course ]
    u.teams << teams.sample
  end
end
puts "Generated #{students.count} unruly students"

# Generate sample admin
User.create! do |u|
  u.username = 'albus'
  u.first_name = 'Albus'
  u.last_name = 'Dumbledore'
  u.role = 'admin'
  u.email = 'dumbledore@hogwarts.edu'
  u.password = 'fawkes'
  u.save!
  courses.each do |c|
    u.course_memberships.create! do |cm|
      cm.course = c
      cm.role = "professor"
    end
  end
end
puts "Albus Dumbledore just apparated into Hogwarts"

# Generate sample professor
User.create! do |u|
  u.username = 'severus'
  u.first_name = 'Severus'
  u.last_name = 'Snape'
  u.role = 'professor'
  u.email = 'snape@hogwarts.edu'
  u.password = 'lily'
  u.save!
  u.course_memberships.create! do |cm|
    cm.course = information_course
    cm.role = "professor"
  end
end
puts "Severus Snape has been spotted in Slytherin House"

# Generate sample professor
User.create! do |u|
  u.username = 'mcgonagall'
  u.first_name = 'Minerva'
  u.last_name = 'McGonagall'
  u.role = 'professor'
  u.email = 'mcgonagall@hogwarts.edu'
  u.password = 'pineanddragonheart'
  u.save!
  u.course_memberships.create! do |cm|
    cm.course = educ_course
    cm.role = "professor"
  end 
end
puts "Headmistress McGonagall is here...shape up!"

# Generate sample professor
User.create! do |u|
  u.username = 'headless_nick'
  u.first_name = 'Nicholas'
  u.last_name = 'de Mimsy-Porpington'
  u.role = 'professor'
  u.email = 'headless_nick@hogwarts.edu'
  u.password = 'october31'
  u.save!
  u.course_memberships.create! do |cm|
    cm.course = polsci_course
    cm.role = "professor"
  end
end
puts "Shhhh... he hates being called Nearly Headless Nick!"

# Generate sample GSI
User.create! do |u|
  u.username = 'percy.weasley'
  u.first_name = 'Percy'
  u.last_name = 'Weasley'
  u.role = 'gsi'
  u.email = 'percy.weasley@hogwarts.edu'
  u.password = 'bestprefect'
  u.save!
  courses.each do |c|
    u.course_memberships.create! do |cm|
      cm.course = c
      cm.role = "gsi"
    end
  end
end
puts "Percy Weasley has arrived on campus, on time as usual"

#Create demo academic history content
students.each do |s|
  StudentAcademicHistory.create! do |ah|
    ah.student_id = s.id
    ah.major = majors.sample
    ah.gpa = [1.5, 2.0, 2.25, 2.5, 2.75, 3.0, 3.33, 3.5, 3.75, 4.0, 4.1].sample
    ah.current_term_credits = rand(12)
    ah.accumulated_credits = rand(40)
    ah.year_in_school = [1, 2, 3, 4, 5, 6, 7].sample
    ah.state_of_residence = "Michigan"
    ah.high_school = "Farwell Timberland Alternative High School"
    ah.athlete = [false, true].sample
    ah.act_score = (1..32).to_a.sample
    ah.sat_score = 100 * rand(10)
  end
end
puts "And gave students some background"

educ_badges = educ_badge_names.map do |badge_name|
  educ_course.badges.create! do |b|
    b.name = badge_name
    b.point_total = 100 * rand(10)
    b.visible = 1
  end
end
puts "Did someone need motivation? We found these badges in the Room of Requirements..."

educ_badges.each do |badge|
  students.each do |student|
    student.earned_badges.create! do |eb|
      eb.badge = badge
      eb.course = educ_course
    end
  end
end
puts "Earned badges have been awarded"

polsci_badges = polsci_badge_names.map do |badge_name|
  polsci_course.badges.create! do |b|
    b.name = badge_name
    b.point_total = 100 * rand(10)
    b.visible = 1
  end
end
puts "How will you be powering up?"

polsci_badges.each do |badge|
  students.each do |student|
    student.earned_badges.create! do |eb|
      eb.badge = badge
      eb.course = polsci_course
    end
  end
end
puts "Power ups in play... use with caution"


assignment_types = {}

assignment_types[:educ_attendance] = AssignmentType.create! do |at|
  at.course = educ_course
  at.name = "Attendance"
  at.point_setting = "For All Assignments"
  at.points_predictor_display = "Slider"
  at.resubmission = false
  at.max_value = "120000"
  at.predictor_description = "We will work to build a learning community in EDUC 222, and I want this to be a great learning experience for all. To do this requires that you commit to the class and participate."
  at.universal_point_value = "5000"
  at.due_date_present = true
  at.order_placement = 1
  at.mass_grade_type = "Checkbox"
end
puts "Come to class."

1.upto(5).each do |n|
  assignment_types[:educ_attendance].score_levels.create do |sl|
    sl.name = "#{n}0% of class"
    sl.value = 5000/n
  end
end
puts "Added slider grading levels for EDUC pro-rated attendance"

assignment_types[:polsci_attendance] = AssignmentType.create! do |at|
  at.course = polsci_course
  at.name = "Attendance"
  at.point_setting = "For All Assignments"
  at.points_predictor_display = "Checkbox"
  at.resubmission = false
  at.predictor_description = "We will work to build a learning community in EDUC 222, and I want this to be a great learning experience for all. To do this requires that you commit to the class and participate."
  at.universal_point_value = "100"
  at.due_date_present = true
  at.order_placement = 1
  at.mass_grade_type = "Checkbox"
  at.student_logged_button_text = "I'm in class!"
  at.student_logged_revert_button_text = "I couldn't make it"
end
puts "Check yourself in - and be sure to pay attention to the lecture!"

assignment_types[:information_adventures] = AssignmentType.create! do |at|
  at.course = information_course
  at.name = "Adventures"
  at.point_setting = "By Assignment"
  at.points_predictor_display = "Set per Assignment"
  at.resubmission = false
  at.due_date_present = true
  at.mass_grade_type = "Set per Assignment"
end

assignment_types[:information_pick_up_quests] = AssignmentType.create! do |at|
  at.course = information_course
  at.name = "Pick Up Quests"
  at.point_setting = "By Assignment"
  at.points_predictor_display = "Set per Assignment"
  at.resubmission = false
  at.due_date_present = true
  at.mass_grade_type = "Set per Assignment"
end

assignment_types[:reading_reaction] = AssignmentType.create! do |at|
  at.course = educ_course
  at.name = "Reading Reactions"
  at.universal_point_value = 5000
  at.point_setting = "For All Assignments"
  at.points_predictor_display = "Select List"
  at.resubmission = false
  at.predictor_description = "Each week, you must write a concise summary or analysis of the reading for that week of no more than 200 words! (200 words is roughly equivalent to one-half page, double-spaced.) Your 201st word will suffer a terrible fate... "
  at.due_date_present = true
  at.order_placement = 2
  at.mass_grade = true
  at.mass_grade_type = "Select List"
  at.student_weightable = false
end
puts "Do your readings."

assignment_types[:reading_reaction].score_levels.create do |sl|
  sl.name = "You Reacted"
  sl.value = 2500
end

assignment_types[:polsci_discussion] = AssignmentType.create! do |at|
  at.course = polsci_course
  at.name = "Discussions"
  at.universal_point_value = 500
  at.point_setting = "For All Assignments"
  at.points_predictor_display = "Checkbox"
  at.resubmission = false
  at.predictor_description = "Each week, you must write a concise summary or analysis of the reading for that week of no more than 200 words! (200 words is roughly equivalent to one-half page, double-spaced.) Your 201st word will suffer a terrible fate... "
  at.due_date_present = true
  at.order_placement = 2
  at.mass_grade_type = "Select List"
  at.student_weightable = false
end
puts "Participate."

assignment_types[:polsci_readings] = AssignmentType.create! do |at|
  at.course = polsci_course
  at.name = "Readings"
  at.universal_point_value = 300
  at.point_setting = "For All Assignments"
  at.points_predictor_display = "Checkbox"
  at.resubmission = false
  at.predictor_description = "Each week, you must write a concise summary or analysis of the reading for that week of no more than 200 words! (200 words is roughly equivalent to one-half page, double-spaced.) Your 201st word will suffer a terrible fate... "
  at.due_date_present = true
  at.mass_grade_type = "Select List"
  at.student_weightable = false
end
puts "Read or else."

assignment_types[:blogging] = AssignmentType.create! do |at|
  at.course = educ_course
  at.name = "Blogging"
  at.point_setting = "By Assignment"
  at.points_predictor_display = "Slider"
  at.resubmission = false
  at.max_value = "60000"
  at.predictor_description = "There will be many issues and topics that we address in this course that spark an interest, an idea, a disagreement, or a connection for you. You will also encounter ideas in your daily life (blogs you read, news reports, etc.) or in your other classes that spark a connection to something you are thinking about in this course. I encourage you to blog these thoughts on Piazza (we will pretend that Piazza is a blogging site for the purposes of this course). These may be analyses, critiques, or reviews of ideas both from and related to the course. Use the blog as a way to expand the range of technology we might consider. Use the blog to challenge ideas. Use the blog to communicate about things you come across in your travels that you think are relevant to the area of teaching and learning with technology.

Note that blog posts must be substantial to earn points. What “substantial” means is at the discretion of the professor (he knows it when he sees it). “Hello World” posts or posts that are simply duplications from other sites are not going to earn you any points. Also, see this insightful resource for information about plagiarism and blogging:
http://www.katehart.net/2012/06/citing-sources-quick-and-graphic-guide.html

You can blog as much as you want, but only one post/week can earn points."
  at.order_placement = 3
  at.mass_grade = true
  at.mass_grade_type = "Radio Buttons"
  at.student_weightable = true
end
puts "Blogging is great for filling in missed points in other areas"

assignment_types[:lfpg] = AssignmentType.create! do |at|
  at.course = educ_course
  at.name = "20% Time"
  at.point_setting = "By Assignment"
  at.points_predictor_display = "Slider"
  at.predictor_description = "At Google, all employs were (historically) given 20% of their work time to devote to any project they choose. Often, these projects fold the personal interest or ambitions of the employee into the larger opportunities represented by the context of Google (e.g., high-tech resources and lots of smart folks). In this course, I am requiring that you devote 20% of your time to pursuing a project of interest to you, that benefits you, and that will help you maximize the value of this course for you. You will determine the scope of the project, the requirements of the project, and the final grade for the project. You may work alone or with others. Whether or not there is a “product” is up to you, as is the form of that product. There is only one requirement for this project: You must share or present the project (in some way of your choosing) with your classmates and with me at the final class meeting.

We will make time during class for sharing, design jams, help sessions, etc. as we go along. The point of these sessions will be to inspire each other and yourself by seeing what others are up to. My office hours are also available to you for as much advice and guidance as you want to seek to support your work (sign up at http://bit.ly/16Ws5fm).

At the end of the term, you will tell me how many points out of the 20,000 you have earned.

I look forward to being surprised, elated, and informed by your interests and self-expression."
  at.resubmission = false
  at.due_date_present = true
  at.order_placement = 4
  at.mass_grade = false
  at.student_weightable = true
end
puts "This is the good stuff :)"

assignment_types[:boss_battle] = AssignmentType.create! do |at|
  at.course = educ_course
  at.name = "Boss Battles"
  at.point_setting = "By Assignment"
  at.points_predictor_display = "Set per Assignment"
  at.resubmission = true
  at.due_date_present = true
  at.order_placement = 5
  at.mass_grade = false
end
puts "Challenges!"

assignment_types[:polsci_essays] = AssignmentType.create! do |at|
  at.course = polsci_course
  at.name = "Conventional Academic Essays"
  at.point_setting = "By Assignment"
  at.points_predictor_display = "Set per Assignment"
  at.resubmission = true
  at.mass_grade_type = "Radio Buttons"
  at.student_weightable = true
end
puts "Essays are one path to success. How much do you like writing?"

assignment_types[:polsci_boss] = AssignmentType.create! do |at|
  at.course = polsci_course
  at.name = "Boss Battles"
  at.point_setting = "By Assignment"
  at.points_predictor_display = "Set per Assignment"
  at.resubmission = false
  at.mass_grade_type = "Radio Buttons"
  at.student_weightable = true
end
puts "How good are you under pressure?"

assignment_types[:polsci_group] = AssignmentType.create! do |at|
  at.course = polsci_course
  at.name = "Group Project"
  at.point_setting = "By Assignment"
  at.points_predictor_display = "Set per Assignment"
  at.resubmission = true
  at.mass_grade_type = "Radio Buttons"
  at.student_weightable = true
end
puts "So uh, do you make friends easily?"

assignment_types[:polsci_blogging] = AssignmentType.create! do |at|
  at.course = polsci_course
  at.name = "Blogging"
  at.point_setting = "By Assignment"
  at.points_predictor_display = "Set per Assignment"
  at.resubmission = true
  at.mass_grade_type = "Radio Buttons"
  at.student_weightable = true
end
puts "You ever blogged before?"

grinding_assignments = []

1.upto(30).each do |n|
  grinding_assignments << assignment_types[:educ_attendance].assignments.create! do |a|
    a.course = educ_course
    a.name = "Class #{n}"
    a.point_total = 5000
    a.accepts_submissions = false
    a.release_necessary = false
    a.grade_scope = "Individual"
    if n < 15
      a.due_at = ((15-n)/2).weeks.ago
    else
      a.due_at = ((-15 + n)/2).weeks.from_now
    end
  end
end

1.upto(30).each do |n|
  grinding_assignments << assignment_types[:polsci_attendance].assignments.create! do |a|
    a.course = polsci_course
    a.name = "Class #{n}"
    a.point_total = 100
    a.accepts_submissions = false
    a.release_necessary = false
    a.grade_scope = "Individual"
    a.student_logged = true
    if n < 15
      a.due_at = ((15-n)/2).weeks.ago
    else
      a.due_at = ((-15 + n)/2).weeks.from_now
    end
  end
end

1.upto(15).each do |n|
  grinding_assignments << assignment_types[:reading_reaction].assignments.create! do |a|
    a.course = educ_course
    a.name = "Reading Reaction #{n}"
    if n < 15
      a.due_at = (7-n).weeks.ago
    else
      a.due_at = (-7 + n).weeks.from_now
    end
    a.accepts_submissions = false
    a.release_necessary = false
    a.grade_scope = "Individual"
  end
end

1.upto(30).each do |n|
  grinding_assignments << assignment_types[:polsci_readings].assignments.create! do |a|
    a.course = polsci_course
    a.name = "Reading #{n}"
    if n < 15
      a.due_at = ((15-n)/2).weeks.ago
    else
      a.due_at = ((-15 + n)/2).weeks.from_now
    end
    a.accepts_submissions = false
    a.release_necessary = false
    a.grade_scope = "Individual"
  end
end

1.upto(15).each do |n|
  grinding_assignments << assignment_types[:polsci_discussion].assignments.create! do |a|
    a.course = polsci_course
    a.name = "Discussion #{n}"
    if n < 15
      a.due_at = (7-n).weeks.ago
    else
      a.due_at = (-7 + n).weeks.from_now
    end
    a.accepts_submissions = false
    a.release_necessary = false
    a.grade_scope = "Individual"
  end
end

grinding_assignments.each do |a|
  a.tasks.create! do |t|
    t.assignment = a
    t.name = "Task 1"
    t.due_at = a.due_at
    t.accepts_submissions = true
  end
end

puts "Attendance and Reading Reaction classes have been posted!"

grinding_assignments.each do |assignment|
  next unless assignment.due_at.past?
  students.each do |student|
    assignment.tasks.each do |task|
      submission = student.submissions.create! do |s|
        s.task = task
        s.text_comment = "Wingardium Leviosa"
        s.link = "http://www.twitter.com"
      end
      student.grades.create! do |g|
        g.submission = submission
        g.raw_score = assignment.point_total * [0, 1].sample
        g.status = "Graded"
      end
    end
  end
end
puts "Attendance and Reading Reaction scores have been posted!"

blog_assignments = []

1.upto(15).each do |n|
  blog_assignments << Assignment.create! do |a|
    a.course = educ_course
    a.assignment_type = assignment_types[:blogging]
    a.name = "Blog Post #{n}"
    a.point_total = 5000
    a.accepts_submissions = true
    a.release_necessary = false
    a.grade_scope = "Individual"

    if n < 7
      a.due_at = (7-n).weeks.ago
    else
      a.due_at = (-7 + n).weeks.from_now
    end
  end

  blog_assignments << Assignment.create! do |a|
    a.course = educ_course
    a.assignment_type = assignment_types[:blogging]
    a.name = "Blog Comment #{n}"
    a.point_total = 2000
    a.accepts_submissions = true
    a.release_necessary = false
    a.grade_scope = "Individual"

    if n < 7
      a.due_at = (7-n).weeks.ago
    else
      a.due_at = (-7 + n).weeks.from_now
    end
  end
end

blog_assignments.each do |a|
  a.tasks.create! do |t|
    t.name = "Task 1"
    t.due_at = a.due_at
    t.accepts_submissions = true
  end
end

puts "Blogging assignments have been posted!"

blog_assignments.each_with_index do |assignment, i|
  next if i % 2 == 0
  students.each do |student|
    assignment.tasks.each do |task|
      submission = student.submissions.create! do |s|
        s.task = task
        s.text_comment = "Wingardium Leviosa"
        s.link = "http://www.twitter.com"
      end
      student.grades.create! do |g|
        g.submission = submission
        g.raw_score = assignment.point_total * [0, 1].sample
        g.status = "Graded"
      end
    end
  end
end
puts "Blogging scores have been posted!"

assignments = []

assignments << Assignment.create! do |a|
  a.course = educ_course
  a.assignment_type = assignment_types[:lfpg]
  a.name = "Game Selection Paper"
  a.point_total = 80000
  a.due_at = 3.weeks.ago
  a.accepts_submissions = true
  a.release_necessary = true
  a.open_at = 3.weeks.ago
  a.grade_scope = "Individual"
  a.save
  a.tasks.create! do |t|
    t.name = "Task 1"
    t.due_at = rand.weeks.from_now
    t.accepts_submissions = true
  end
  students.each do |student|
    a.tasks.each do |task|
      submission = student.submissions.create! do |s|
        s.task = task
        s.text_comment = "Wingardium Leviosa"
        s.link = "http://www.twitter.com"
      end
      student.grades.create! do |g|
        g.submission = submission
        g.raw_score = 80000 * [0,1].sample
        g.status = "Graded"
      end
    end
  end
end
puts "Game Selection Paper has been posted!"

assignments << Assignment.create! do |a|
  a.course = educ_course
  a.assignment_type = assignment_types[:lfpg]
  a.name = "Game Play Update Paper 1"
  a.point_total = 120000
  a.due_at = 1.week.ago
  a.accepts_submissions = true
  a.release_necessary = false
  a.open_at = 1.week.ago
  a.grade_scope = "Individual"
end
puts "Game Play Update Paper 1 has been posted!"

assignments << Assignment.create! do |a|
  a.course = educ_course
  a.assignment_type = assignment_types[:lfpg]
  a.name = "Game Play Update Paper 2"
  a.point_total = 120000
  a.due_at = 2.weeks.from_now
  a.accepts_submissions = true
  a.release_necessary = false
  a.open_at = 2.weeks.from_now
  a.grade_scope = "Individual"
end
puts "Game Play Update Paper 2 has been posted!"

assignments << Assignment.create! do |a|
  a.course = educ_course
  a.assignment_type = assignment_types[:lfpg]
  a.name = "Game Play Reflection Paper"
  a.point_total = 160000
  a.due_at = 4.weeks.from_now
  a.accepts_submissions = true
  a.release_necessary = true
  a.open_at = 4.weeks.from_now
  a.grade_scope = "Individual"
end
puts "Game Play Reflection Paper has been posted!"

ip1_assignment = Assignment.create! do |a|
  a.course = educ_course
  a.assignment_type = assignment_types[:boss_battle]
  a.name = "Individual Paper/Project 1"
  a.point_total = 200000
  a.due_at = 4.weeks.from_now
  a.accepts_submissions = true
  a.release_necessary = false
  a.open_at = 4.weeks.from_now
  a.grade_scope = "Individual"
end
puts "Individual Project 1 has been posted!"

1.upto(5).each do |n|
  ip1_assignment.assignment_score_levels.create! do |asl|
    asl.name = "Assignment Score Level ##{n}"
    asl.value = 200000/n
  end
end

ip2_assignment = Assignment.create! do |a|
  a.course = educ_course
  a.assignment_type = assignment_types[:boss_battle]
  a.name = "Individual Paper/Project 2"
  a.point_total = 300000
  a.due_at = 4.weeks.from_now
  a.accepts_submissions = true
  a.release_necessary = false
  a.open_at = 4.weeks.from_now
  a.grade_scope = "Individual"
end
puts "Individual Project 2 has been posted!"

1.upto(8).each do |n|
  ip2_assignment.assignment_score_levels.create! do |asl|
    asl.name = "Assignment Score Level ##{n}"
    asl.value = 300000/(9-n)
  end
end

ggd_assignment = Assignment.create! do |a|
  a.course = educ_course
  a.assignment_type = assignment_types[:boss_battle]
  a.name = "Group Game Design Project"
  a.point_total = 400000
  a.due_at = 4.weeks.from_now
  a.accepts_submissions = true
  a.release_necessary = false
  a.open_at = 4.weeks.from_now
  a.grade_scope = "Group"
end
puts "Group Game Design has been posted!"

1.upto(4).each do |n|
  ggd_assignment.assignment_score_levels.create! do |asl|
    asl.name = "Assignment Score Level ##{n}"
    asl.value = 400000/n
  end
end

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_essays]
  a.name = "First Essay"
  a.point_total = 1000
  a.due_at = 3.weeks.ago
  a.accepts_submissions = true
  a.release_necessary = true
  a.open_at = 3.weeks.ago
  a.grade_scope = "Individual"
  a.save
  a.tasks.create! do |t|
    t.name = "Task 1"
    t.due_at = rand.weeks.from_now
    t.accepts_submissions = true
  end
  students.each do |student|
    a.tasks.each do |task|
      submission = student.submissions.create! do |s|
        s.task = task
        s.text_comment = "Wingardium Leviosa"
        s.link = "http://www.twitter.com"
      end
      student.grades.create! do |g|
        g.submission = submission
        g.raw_score = 1000 * [0,1].sample
        g.status = "Graded"
      end
    end
  end
end
puts "First Conventional Essay has been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_essays]
  a.name = "Second Essay"
  a.point_total = 3000
  a.due_at = 3.weeks.from_now
  a.accepts_submissions = true
  a.release_necessary = true
  a.open_at = 3.weeks.from_now
  a.grade_scope = "Individual"
end
puts "Second Conventional Essay has been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_boss]
  a.name = "Boss Battle I"
  a.point_total = 500
  a.due_at = 7.weeks.ago
  a.accepts_submissions = false
  a.release_necessary = true
  a.open_at = 3.weeks.from_now
  a.grade_scope = "Individual"
end
puts "First Boss Battle has been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_boss]
  a.name = "Boss Battle II"
  a.point_total = 1000
  a.due_at = 1.week.ago
  a.accepts_submissions = false
  a.release_necessary = true
  a.grade_scope = "Individual"
end
puts "Second Boss Battle has been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_boss]
  a.name = "Boss Battle III"
  a.point_total = 1500
  a.due_at = 2.weeks.from_now
  a.accepts_submissions = false
  a.release_necessary = true
  a.grade_scope = "Individual"
end
puts "Third Boss Battle has been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_boss]
  a.name = "Boss Battle IV"
  a.point_total = 1000
  a.due_at = 4.weeks.from_now
  a.accepts_submissions = false
  a.release_necessary = true
  a.grade_scope = "Individual"
end
puts "Fourth Boss Battle has been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_group]
  a.name = "Group Project Proposal"
  a.point_total = 1000
  a.due_at = 4.weeks.ago
  a.accepts_submissions = true
  a.release_necessary = true
  a.grade_scope = "Group"
end
puts "Group Project Proposal has been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_group]
  a.name = "Group Project Progress Report"
  a.point_total = 1000
  a.due_at = 1.weeks.ago
  a.accepts_submissions = true
  a.release_necessary = true
  a.grade_scope = "Group"
end
puts "Group Project Progress Report has been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_group]
  a.name = "Group Project Final Report"
  a.point_total = 2000
  a.due_at = 1.weeks.ago
  a.accepts_submissions = true
  a.release_necessary = true
  a.grade_scope = "Group"
end
puts "Group Project Final Report has been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_blogging]
  a.name = "Blog Post 1"
  a.point_total = 500
  a.accepts_submissions = true
  a.release_necessary = true
  a.grade_scope = "Individual"
end

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_blogging]
  a.name = "Blog Post 2"
  a.point_total = 500
  a.accepts_submissions = true
  a.release_necessary = true
  a.grade_scope = "Individual"
end
puts "Blog 2 has been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_blogging]
  a.name = "Blog Post 3"
  a.point_total = 500
  a.accepts_submissions = true
  a.release_necessary = true
  a.grade_scope = "Individual"
end
puts "Blog 3 has been posted!" 

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_blogging]
  a.name = "Blog Post 4"
  a.point_total = 500
  a.accepts_submissions = true
  a.release_necessary = true
  a.grade_scope = "Individual"
end
puts "Blog 4 has been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_blogging]
  a.name = "Extra Blog Post (invisible)"
  a.point_total = 500
  a.accepts_submissions = true
  a.release_necessary = true
  a.grade_scope = "Individual"
  a.visible = false
end
puts "Extra Blog post has been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_blogging]
  a.name = "Blog Comments"
  a.point_total = 1000
  a.accepts_submissions = true
  a.release_necessary = true
  a.grade_scope = "Individual"
  a.visible = false
end
puts "Blog comments have been posted!"

assignments << Assignment.create! do |a|
  a.course = polsci_course
  a.assignment_type = assignment_types[:polsci_blogging]
  a.name = "Blog Portfolio"
  a.point_total = 1000
  a.accepts_submissions = true
  a.release_necessary = true
  a.grade_scope = "Individual"
end
puts "Blog Portfolio have been posted!"

challenges = []

challenges << Challenge.create! do |c|
  c.course = educ_course
  c.name = "House Cup"
  c.point_total = 1000000
  c.due_at = 3.week.ago
  c.accepts_submissions = true
  c.release_necessary = false
  c.open_at = rand(6).weeks.from_now
  c.visible = true
  c.save
  teams.each do |team|
    c.challenge_grades.create! do |cg|
      cg.team = team
      cg.score = 1000000 * [0,1].sample
      cg.status = "Graded"
    end
  end
end
puts "The House Cup Competition begins... "

challenges << Challenge.create! do |c|
  c.course = educ_course
  c.name = "Tri-Wizard Tournament"
  c.point_total = 10000000
  c.due_at = 2.weeks.ago
  c.accepts_submissions = true
  c.release_necessary = false
  c.open_at = rand(8).weeks.from_now
  c.visible = true
end
puts "Are you willing to brave the Tri-Wizard Tournament?"

LTIProvider.create! do |p|
  p.name = 'Piazza'
  p.uid = 'piazza'
  p.launch_url = 'https://piazza.com/connect'
  p.consumer_key = 'piazza.sandbox'
  p.consumer_secret = 'test_only_secret'
end


