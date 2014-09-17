class ChallengesController < ApplicationController

  before_filter :ensure_staff?, :except=>[:index, :show]

  def index
    @title = "View All #{term_for :challenges}"
    @challenges = current_course.challenges
  end

  def show
    @challenge = current_course.challenges.find(params[:id])
    @title = @challenge.name
    @teams = current_course.teams
  end

  def new
    @challenge = current_course.challenges.new
    @title = "Create a New #{term_for :challenge}"
  end

  def edit
    @challenge = current_course.challenges.find(params[:id])
    @title = "Editing #{@challenge.name}"
  end

  def create
    @challenge = current_course.challenges.create(params[:challenge])

    if @challenge.due_at.present? && @challenge.open_at.present? && @challenge.due_at < @challenge.open_at
      flash[:error] = 'Due date must be after open date.'
      render :action => "new", :challenge => @challenge
    elsif (@challenge.point_total.present?) && (@challenge.point_total < 1)
      flash[:error] = 'Point total must be a positive number'
      render :action => "new", :challenge => @challenge
    else
      respond_to do |format|
        if @challenge.save
          self.check_uploads
          format.html { redirect_to @challenge, notice: "Challenge #{@challenge.name} successfully created" }
          format.json { render json: @challenge, status: :created, location: @challenge }
        else
          format.html { render action: "new" }
          format.json { render json: @challenge.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    @challenge = current_course.challenges.includes(:challenge_score_levels).find(params[:id])
    @challenge.assign_attributes(params[:challenge])
    @title = "Editing #{@challenge.name}"
    respond_to do |format|
      if @challenge.due_at.present? && @challenge.open_at.present? && @challenge.due_at < @challenge.open_at
        flash[:error] = 'Due date must be after open date.'
        format.html { render action: "edit" }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      elsif (@challenge.point_total.present?) && (@challenge.point_total < 1)
        flash[:error] = 'Point total must be a positive number'
        format.html { render action: "edit" }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      else
        if @challenge.save
          self.check_uploads
          format.html { redirect_to @challenge, notice: "Challenge #{@challenge.name} successfully updated" }
          format.json { head :ok }
        else
          format.html { render action: "edit" }
          format.json { render json: @challenge.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @challenge = current_course.challenges.find(params[:id])
    @name = "#{@challenge.name}"
    @challenge.destroy

    respond_to do |format|
      format.html { redirect_to challenges_path, notice: "Challenge #{@name} successfully deleted" }
      format.json { head :ok }
    end
  end

  def check_uploads
    if params[:challenge][:challenge_files_attributes]["0"][:filepath].empty?
      params[:challenge].delete(:challenge_files_attributes)
      @challenge.challenge_files.destroy_all
    end
  end

end
