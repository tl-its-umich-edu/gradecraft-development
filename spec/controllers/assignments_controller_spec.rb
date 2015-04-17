require 'spec_helper'

describe AssignmentsController do

  context "as a student" do
    before do
      @course = create(:course_accepting_groups)
      @student = create(:user)
      @student.courses << @course
      login_user(@student)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

    describe "GET index" do
      it "redirects to syllabus path" do
        (get :index).should redirect_to("/syllabus")
      end
    end

    describe "GET show" do

      before do
        assignment_type = create(:assignment_type, course: @course)
        @assignment = create(:assignment)
        @course.assignments << @assignment
      end

      it "returns the assignment show page" do
        get :show, :id => @assignment.id
        assigns(:assignment).should eq(@assignment)
        assigns(:assignment_type).should eq(@assignment.assignment_type)
        assigns(:title).should eq(@assignment.name)
        response.should render_template(:show)
      end

      it "assigns groups" do
        group = create(:group, course: @course)
        group.assignments << @assignment
        get :show, :id => @assignment.id
        assigns(:groups).should eq([group])
      end

      it "assigns assignment_grades_by_student_id" do
        grade = create(:grade, assignment: @assignment, student: @student)
        get :show, :id => @assignment.id
        assigns(:assignment_grades_by_student_id).should eq({@student.id => grade})
      end

      describe "with team id in params" do
        it "assigns team and students for team" do
          # we verify only students on team assigned as @students
          other_student = create(:user)
          other_student.courses << @course

          team = create(:team, course: @course)
          team.students << @student

          get :show, {:id => @assignment.id, :team_id => team.id}
          assigns(:team).should eq(team)
          assigns(:students).should eq([@student])
        end

        it "assigns all team students auditing as auditors" do
          # we verify only auditing students on team assigned as @auditing
          other_student = create(:user)
          other_student.courses << @course

          team = create(:team, course: @course)
          team.students << @student
          @student.course_memberships.first.update(auditing: true)
          other_student.course_memberships.first.update(auditing: true)

          get :show, {:id => @assignment.id, :team_id => team.id}
          assigns(:auditors).should eq([@student])
        end
      end

      describe "with no team id in params" do
        it "assigns all students if no team supplied" do
          # we verify non-team members also assigned as @students
          other_student = create(:user)
          other_student.courses << @course

          team = create(:team, course: @course)
          team.students << @student

          get :show, :id => @assignment.id
          assigns(:students).should include(@student)
          assigns(:students).should include(other_student)
        end

        it "assigns all auditing students as auditors" do
          @student.course_memberships.first.update(auditing: true)
          get :show, :id => @assignment.id
          assigns(:auditors).should eq([@student])
        end
      end

      it "assigns the rubric as rubric" do
        rubric = create(:rubric_with_metrics, assignment: @assignment)
        get :show, :id => @assignment.id
        assigns(:rubric).should eq(rubric)
        assigns(:metrics).should eq(rubric.metrics)
      end

      it "assigns course badges as JSON using CourseBadgeSerializer" do
        badge = create(:badge, course: @course)
        get :show, :id => @assignment.id
        assigns(:course_badges).should eq(ActiveModel::ArraySerializer.new([badge], each_serializer: CourseBadgeSerializer).to_json)
      end

      it "assigns assignment score levels ordered by value" do
        assignment_score_level_second = create(:assignment_score_level, assignment: @assignment, value: "1000")
        assignment_score_level_first = create(:assignment_score_level, assignment: @assignment, value: "100")
        get :show, :id => @assignment.id
        assigns(:assignment_score_levels).should eq([assignment_score_level_first,assignment_score_level_second])
      end

      it "assigns student ids" do
        get :show, :id => @assignment.id
        assigns(:course_student_ids).should eq([@student.id])
      end

      it "assigns data for displaying student grading distribution" do
        pending "need to create a scored grade"
        ungraded_submission = create(:submission, assignment: @assignment)
        student_submission = create(:graded_submission, assignment: @assignment, student: @student)
        @assignment.submissions << [student_submission, ungraded_submission]
        get :show, :id => @assignment.id
        assigns(:submissions_count).should eq(2)
        assigns(:ungraded_submissions_count).should eq(1)
        assigns(:ungraded_percentage).should eq(1/2)
        assigns(:graded_count).should eq(1)
      end

      # GET show, student specific specs:

      it "assigns grades for assignment" do
        grade = create(:grade, student: @student, assignment: @assignment)
        get :show, :id => @assignment.id
        assigns(:grades_for_assignment).should eq(@assignment.grades_for_assignment(@student))
      end

      it "assigns rubric grades" do
        pending
        rubric = create(:rubric_with_metrics, assignment: @assignment)
        # TODO: Test for this line:
        # @rubric_grades = RubricGrade.joins("left outer join submissions on submissions.id = rubric_grades.submission_id").where(student_id: current_user[:id]).where(assignment_id: params[:id])
        get :show, :id => @assignment.id
        assigns(:rubric_grades).should eq("?")
      end

      it "assigns comments by metric id" do
        pending
        get :show, :id => @assignment.id
        assigns(:comments_by_metric_id).should eq("?")
      end

      it "assigns group if student is in a group" do
        @assignment.update(grade_scope: "Group")
        group = create(:group, course: @course)
        group.assignments << @assignment
        group.students << @student
        get :show, :id => @assignment.id
        assigns(:group).should eq(group)
      end
    end

    describe "GET feed" do
      it "returns a calendar event" do
        assignment_type = create(:assignment_type, course: @course)
        timestamp = Time.new
        assignment = create(:assignment, assignment_type: assignment_type, due_at: timestamp)
        @course.assignments << assignment

        get :feed, :format => :ics
        assigns(:assignments).should eq([assignment])
        response.body.should include(assignment.name)
        response.body.should include(timestamp.strftime("%Y%m%d"))
      end
    end

    describe "protected routes" do
      [
        :new,
        :copy,
        :create,
        :sort

      ].each do |route|
        it "#{route} redirects to root" do
          (get route).should redirect_to(:root)
        end
      end
    end

    describe "protected routes requiring id in params" do
      [
        :edit,
        :update,
        :destroy,
        :export_grades,
        :email_based_grade_import,
        :username_based_grade_import,
        :update_rubrics,
        :rubric_grades_review

      ].each do |route|
        it "#{route} redirects to root" do
          (get route, {:id => "1"}).should redirect_to(:root)
        end
      end
    end
  end

  context "as a professor" do
    before do
      @course = create(:course_accepting_groups)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @assignment_type = create(:assignment_type, course: @course)
      @assignment = create(:assignment, assignment_type: @assignment_type)
      @course.assignments << @assignment
      @student = create(:user)
      @student.courses << @course

      login_user(@professor)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

    describe "GET index" do
      it "returns assignments for the current course" do
        get :index
        assigns(:title).should eq("assignments")
        assigns(:assignment_types).should eq([@assignment_type])
        assigns(:assignments).should eq([@assignment])
        response.should render_template(:index)
      end
    end

    describe "GET settings" do
      it "returns title and assignments" do
        get :settings
        # TODO: notice, lib/course_terms.rb downcases the term_for assignments
        assigns(:title).should eq("Review assignment Settings")
        # TODO: confirm multiple assignments are chronological and alphabetical
        assigns(:assignments).should eq([@assignment])
        response.should render_template(:settings)
      end
    end

    describe "GET show" do

      it "returns the assignment show page" do
        get :show, :id => @assignment.id
        assigns(:assignment).should eq(@assignment)
        assigns(:assignment_type).should eq(@assignment.assignment_type)
        assigns(:title).should eq(@assignment.name)
        response.should render_template(:show)
      end

      it "assigns groups" do
        group = create(:group, course: @course)
        group.assignments << @assignment
        get :show, :id => @assignment.id
        assigns(:groups).should eq([group])
      end

      it "assigns assignment_grades_by_student_id" do
        grade = create(:grade, assignment: @assignment, student: @student)
        get :show, :id => @assignment.id
        assigns(:assignment_grades_by_student_id).should eq({@student.id => grade})
      end

      describe "with team id in params" do
        it "assigns team and students for team" do
          # we verify only students on team assigned as @students
          other_student = create(:user)
          other_student.courses << @course

          team = create(:team, course: @course)
          team.students << @student

          get :show, {:id => @assignment.id, :team_id => team.id}
          assigns(:team).should eq(team)
          assigns(:students).should eq([@student])
        end

        it "assigns all team students auditing as auditors" do
          # we verify only auditing students on team assigned as @auditing
          other_student = create(:user)
          other_student.courses << @course

          team = create(:team, course: @course)
          team.students << @student
          @student.course_memberships.first.update(auditing: true)
          other_student.course_memberships.first.update(auditing: true)

          get :show, {:id => @assignment.id, :team_id => team.id}
          assigns(:auditors).should eq([@student])
        end
      end

      describe "with no team id in params" do
        it "assigns all students if no team supplied" do
          # we verify non-team members also assigned as @students
          other_student = create(:user)
          other_student.courses << @course

          team = create(:team, course: @course)
          team.students << @student

          get :show, :id => @assignment.id
          assigns(:students).should include(@student)
          assigns(:students).should include(other_student)
        end

        it "assigns all auditing students as auditors" do
          @student.course_memberships.first.update(auditing: true)
          get :show, :id => @assignment.id
          assigns(:auditors).should eq([@student])
        end
      end

      it "assigns the rubric as rubric" do
        rubric = create(:rubric_with_metrics, assignment: @assignment)
        get :show, :id => @assignment.id
        assigns(:rubric).should eq(rubric)
        assigns(:metrics).should eq(rubric.metrics)
      end

      it "assigns course badges as JSON using CourseBadgeSerializer" do
        badge = create(:badge, course: @course)
        get :show, :id => @assignment.id
        assigns(:course_badges).should eq(ActiveModel::ArraySerializer.new([badge], each_serializer: CourseBadgeSerializer).to_json)
      end

      it "assigns assignment score levels ordered by value" do
        assignment_score_level_second = create(:assignment_score_level, assignment: @assignment, value: "1000")
        assignment_score_level_first = create(:assignment_score_level, assignment: @assignment, value: "100")
        get :show, :id => @assignment.id
        assigns(:assignment_score_levels).should eq([assignment_score_level_first,assignment_score_level_second])
      end

      it "assigns student ids" do
        get :show, :id => @assignment.id
        assigns(:course_student_ids).should eq([@student.id])
      end

      it "assigns data for displaying student grading distribution" do
        pending "need to create a scored grade"
        ungraded_submission = create(:submission, assignment: @assignment)
        student_submission = create(:graded_submission, assignment: @assignment, student: @student)
        @assignment.submissions << [student_submission, ungraded_submission]
        get :show, :id => @assignment.id
        assigns(:submissions_count).should eq(2)
        assigns(:ungraded_submissions_count).should eq(1)
        assigns(:ungraded_percentage).should eq(1/2)
        assigns(:graded_count).should eq(1)
      end

      # GET show, professor specific:

      it "assigns grades for assignment" do
        grade = create(:grade, student: @student, assignment: @assignment)
        get :show, :id => @assignment.id
        assigns(:grades_for_assignment).should eq(@assignment.all_grades_for_assignment)
      end
    end

    describe "GET new" do
      it "assigns title and assignments" do
        get :new
        assigns(:title).should eq("Create a New assignment")
        assigns(:assignment).should be_a_new(Assignment)
        response.should render_template(:new)
      end
    end

    describe "GET edit" do
      it "assigns title and assignments" do
        get :edit, :id => @assignment.id
        assigns(:title).should eq("Editing #{@assignment.name}")
        assigns(:assignment).should eq(@assignment)
        response.should render_template(:edit)
      end
    end

    describe "GET copy" do
      it "assigns title and assignments" do
        pending "copy fails at assignments, change to assignments_path"
        get :copy, :id => @assignment.id
        response.should render_template(:copy)
      end
    end

    describe "POST create" do
      it "creates the assignment with valid attributes"  do
        params = attributes_for(:assignment)
        params[:assignment_type_id] = @assignment_type
        expect{ post :create, :assignment => params }.to change(Assignment,:count).by(1)
      end

      it "manages file uploads" do
        Assignment.delete_all
        params = attributes_for(:assignment)
        params[:assignment_type_id] = @assignment_type
        params.merge! :assignment_files_attributes => {"0" => {"file" => [fixture_file('test_file.txt', 'txt')]}}
        post :create, :assignment => params
        assignment = Assignment.where(name: params[:name]).last
        expect assignment.assignment_files.count.should eq(1)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, assignment: attributes_for(:assignment, name: nil) }.to_not change(Assignment,:count)
      end
    end

    describe "POST update" do
      it "updates the assignment" do
        params = { name: "new name" }
        post :update, id: @assignment.id, :assignment => params
        @assignment.reload
        response.should redirect_to(assignments_path)
        @assignment.name.should eq("new name")
      end

      it "manages file uploads" do
        params = {:assignment_files_attributes => {"0" => {"file" => [fixture_file('test_file.txt', 'txt')]}}}
        post :update, id: @assignment.id, :assignment => params
        expect @assignment.assignment_files.count.should eq(1)
      end
    end

    describe "GET sort" do
      it "sorts the assignemts by params" do
        @second_assignment = create(:assignment, assignment_type: @assignment_type)
        @course.assignments << @second_assignment
        params = [@second_assignment.id, @assignment.id]
        post :sort, :assignment => params

        @assignment.reload
        @second_assignment.reload
        @assignment.position.should eq(2)
        @second_assignment.position.should eq(1)
      end
    end

    describe "GET update_rubrics" do
      it "assigns true or false to assignment use_rubric" do
        @assignment.update(:use_rubric => false)
        post :update_rubrics, :id => @assignment, :use_rubric => true
        @assignment.reload
        @assignment.use_rubric.should be_true
      end
    end

    describe "GET rubric_grades_review" do
      it "assigns attributes for display" do
        group = create(:group, course: @course)
        group.assignments << @assignment

        get :rubric_grades_review, :id => @assignment
        assigns(:title).should eq(@assignment.name)
        assigns(:assignment).should eq(@assignment)
        assigns(:groups).should eq([group])
        response.should render_template(:rubric_grades_review)
      end

      it "assigns course badges as JSON using CourseBadgeSerializer" do
        badge = create(:badge, course: @course)
        get :rubric_grades_review, :id => @assignment.id
        assigns(:course_badges).should eq(ActiveModel::ArraySerializer.new([badge], each_serializer: CourseBadgeSerializer).to_json)
      end

      it "assigns the rubric as rubric" do
        rubric = create(:rubric_with_metrics, assignment: @assignment)
        get :rubric_grades_review, :id => @assignment.id
        assigns(:rubric).should eq(rubric)
        assigns(:metrics).should eq(rubric.metrics)
      end

      it "assigns assignment score levels ordered by value" do
        assignment_score_level_second = create(:assignment_score_level, assignment: @assignment, value: "1000")
        assignment_score_level_first = create(:assignment_score_level, assignment: @assignment, value: "100")
        get :rubric_grades_review, :id => @assignment.id
        assigns(:assignment_score_levels).should eq([assignment_score_level_first,assignment_score_level_second])
      end

      it "assigns student ids" do
        get :rubric_grades_review, :id => @assignment.id
        assigns(:course_student_ids).should eq([@student.id])
      end

      it "assigns rubric grades" do
        pending
        rubric = create(:rubric_with_metrics, assignment: @assignment)
        # TODO: Test for these lines:
        # @rubric_grades = serialized_rubric_grades
        # @viewable_rubric_grades = RubricGrade.where(assignment_id: @assignment.id)
        get :rubric_grades_review, :id => @assignment.id
        assigns(:rubric_grades).should eq("?")
        assigns(:viewable_rubric_grades).should eq("?")
      end

      it "assigns comments by metric id" do
        pending
        get :rubric_grades_review, :id => @assignment.id
        assigns(:comments_by_metric_id).should eq("?")
      end

      describe "with team id in params" do
        it "assigns team and students for team" do
          # we verify only students on team assigned as @students
          other_student = create(:user)
          other_student.courses << @course

          team = create(:team, course: @course)
          team.students << @student

          get :rubric_grades_review, {:id => @assignment.id, :team_id => team.id}
          assigns(:team).should eq(team)
          assigns(:students).should eq([@student])
        end

        it "assigns all team students auditing as auditors" do
          # we verify only auditing students on team assigned as @auditing
          other_student = create(:user)
          other_student.courses << @course

          team = create(:team, course: @course)
          team.students << @student
          @student.course_memberships.first.update(auditing: true)
          other_student.course_memberships.first.update(auditing: true)

          get :rubric_grades_review, {:id => @assignment.id, :team_id => team.id}
          assigns(:auditors).should eq([@student])
        end
      end

      describe "with no team id in params" do
        it "assigns all students if no team supplied" do
          # we verify non-team members also assigned as @students
          other_student = create(:user)
          other_student.courses << @course

          team = create(:team, course: @course)
          team.students << @student

          get :rubric_grades_review, :id => @assignment.id
          assigns(:students).should include(@student)
          assigns(:students).should include(other_student)
        end

        it "assigns all auditing students as auditors" do
          @student.course_memberships.first.update(auditing: true)
          get :rubric_grades_review, :id => @assignment.id
          assigns(:auditors).should eq([@student])
        end
      end
    end


    describe "GET destroy" do
      it "destroys the assignment" do
        expect{ get :destroy, :id => @assignment }.to change(Assignment,:count).by(-1)
      end
    end

    describe "GET feed" do
      it "returns a calendar event" do
        timestamp = Time.new
        @assignment.update(due_at: timestamp)

        get :feed, :format => :ics
        assigns(:assignments).should eq([@assignment])
        response.body.should include(@assignment.name)
        response.body.should include(timestamp.strftime("%Y%m%d"))
      end
    end

    describe "GET email_based_grade_import" do
      context "with CSV format" do
        it "returns sample csv data" do
          get :email_based_grade_import, :id => @assignment, :format => :csv
          response.body.should include("First Name,Last Name,Email,Score,Feedback")
        end
      end
    end

    describe "GET username_based_grade_import" do
      context "with CSV format" do
        it "returns sample csv data" do
          grade = create(:grade, assignment: @assignment, student: @student, feedback: "good jorb!")
          get :username_based_grade_import, :id => @assignment, :format => :csv
          response.body.should include("First Name,Last Name,Username,Score,Feedback")
        end
      end
    end

    describe "GET export_grades" do
      context "with CSV format" do
        it "returns sample csv data" do
          grade = create(:grade, assignment: @assignment, student: @student, feedback: "good jorb!")
          submission = create(:submission, grade: grade, student: @student, assignment: @assignment)
          get :export_grades, :id => @assignment, :format => :csv
          response.body.should include("First Name,Last Name,Uniqname,Score,Raw Score,Statement,Feedback")
        end
      end
    end

    describe "GET export_submissions" do
      context "with ZIP format" do
        it "returns a zip directory" do
          get :export_submissions, :id => @assignment, :format => :zip
          response.content_type.should eq("application/zip")
        end
      end
    end
  end
end
