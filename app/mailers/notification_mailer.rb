class NotificationMailer < ActionMailer::Base
  default from: 'mailer@gradecraft.com'

  def lti_error(user_info, course_info)
    @user = user_info
    @course = course_info
    mail(:to => 'cholma@umich.edu', :subject => 'Unknown LTI user/course') do |format|
      format.text
      format.html
    end
  end

  def kerberos_error(user_info)
    @user = user_info
    mail(:to => 'cholma@umich.edu', :subject => 'Unknown Kerberos user') do |format|
      format.text
      format.html
    end
  end

  def successful_submission(submission_id)
    @submission = Submission.find submission_id
    @user = @submission.student
    @course = @submission.course
    @assignment = @submission.assignment
    mail(:to => "#{@user[:email]}", :subject => "#{@course[:courseno]} - #{@assignment.name} Submitted") do |format|
      format.text
      format.html
    end
  end

  def new_submission(submission_id)
    @submission = Submission.find submission_id
    @user = @submission.student
    @course = @submission.course
    @assignment = @submission.assignment
    @professor = @course.professor
    mail(:to => @professor.email, :subject => "#{@course[:courseno]} - New Submission to Grade") do |format|
      format.text
      format.html
    end
  end

  def revised_submission(submission_id)
    @submission = Submission.find submission_id
    @user = @submission.student
    @course = @submission.course
    @assignment = @submission.assignment
    @professor = @course.professor
    mail(:to => @professor.email, :subject => "#{@course[:courseno]} - Updated Submission to Grade") do |format|
      format.text
      format.html
    end
  end

  def grade_released(grade_id)
    @grade = Grade.find grade_id
    @user = @grade.student
    @course = @grade.course
    @assignment = @grade.assignment
    mail(:to => @user.email, :subject => "#{@course.courseno} - #{@assignment.name} Graded") do |format|
      format.text
      format.html
    end
  end

  def group_created(group_id)
    @group = Group.find group_id
    @course = @group.course
    @professor = @group.course.professor
    mail(:to => @professor.email, :subject => "#{@course.courseno} - New Group to Review") do |format|
      format.text
      format.html
    end
  end

  def group_notify(group_id)
    @group = Group.find group_id
    @course = @group.course
    @group_members = @group.students
    @group_members.each do |gm|
      mail(:to => gm.email, :subject => "#{@course.courseno} - New Group") do |format|
        @gm = gm
        format.text
        format.html
      end
    end
  end

  def group_status_updated(group_id)
    @group = Group.find group_id
    @course = @group.course
    @group_members = @group.students
    @group_members.each do |gm|
      mail(:to => gm.email, :subject => "#{@course.courseno} - Group #{@group.approved}") do |format|
        @gm = gm
        format.text
        format.html
      end
    end
  end

  def earned_badge_awarded(earned_badge_id)
    @earned_badge = EarnedBadge.find earned_badge_id
    @user = @earned_badge.student
    @course = @earned_badge.course
    mail(:to => @user.email, :subject => "#{@course.courseno} - You've earned a new #{@course.badge_term}!") do |format|
      format.text
      format.html
    end
  end

  def grade_export(course,user,csv_data)
    @user = user
    @course = course
    attachments["#{course.id}.csv"] = {:mime_type => 'tex/csv',:content => csv_data }
    mail(:to =>  @user.email, :bcc=>"admin@gradecraft.com", :subject => "#{course.name} grade export is attached") do |format|
      format.text
      format.html
    end

  end

end
