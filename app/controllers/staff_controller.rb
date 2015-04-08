class StaffController < ApplicationController

  #Staff means everyone on the instructional team - TAs (we call them GSIs) who usually do the grading, the professor, and any administrators

  respond_to :html, :json

  before_filter :ensure_staff?

  def index
    @title = "Staff Index"
    @staff = current_course.staff
  end

  def show
    @user = current_course.users.find(params[:id])
  end

end
