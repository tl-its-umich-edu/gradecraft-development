require 'spec_helper'

describe EarnedBadgesController do

  context "as a professor" do
    before do
      @course = create(:course_accepting_groups)
      @badge = create(:badge)
      @course.badges << @badge

      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")

      @student = create(:user)
      @student.courses << @course

      login_user(@professor)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

    let(:valid_session) { { "current_course" => @course} }

    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, :id => @badge.id
        assigns(:badge).should eq(@badge)
        assigns(:title).should eq("Quick Award #{@badge.name}")
        assigns(:students).should eq([@student])
        response.should render_template(:mass_edit)
      end

      describe "with teams" do
        pending
      end

      describe "when badges can be earned multiple times" do
        it "assigns earned badges according to alphabetized students" do
          @student.update(last_name: "Zed")
          @student2 = create(:user, last_name: "Alpha")
          @student2.courses << @course
          get :mass_edit, :id => @badge.id
          assigns(:earned_badges).count.should eq(2)
          assigns(:earned_badges)[0].student_id.should eq(@student2.id)
          assigns(:earned_badges)[1].student_id.should eq(@student.id)
        end
      end

      describe "when badges can only be earned once" do
        it "assigns earned badges..." do
          pending
        end
      end
    end
  end
end
