class ChallengesController < ApplicationController

  before_filter :ensure_staff?, :except=>[:index, :show]

  def index
    @title = "#{term_for :challenges}"
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
    if params[:challenge][:challenge_files_attributes].present?
      @challenge_files = params[:challenge][:challenge_files_attributes]["0"]["file"]
      params[:challenge].delete :challenge_files_attributes
    end

    @challenge = current_course.challenges.create(params[:challenge])

    if @challenge_files
      @challenge_files.each do |cf|
        @challenge.challenge_files.new(file: cf, filename: cf.original_filename[0..49])
      end
    end

    respond_to do |format|
      if @challenge.save
        format.html { redirect_to @challenge, notice: "Challenge #{@challenge.name} successfully created" }
        format.json { render json: @challenge, status: :created, location: @challenge }
      else
        # TODO: refactor, see submissions_controller
        @title = "Create a New #{term_for :challenge}"
        format.html { render action: "new" }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if params[:challenge][:challenge_files_attributes].present?
      @challenge_files = params[:challenge][:challenge_files_attributes]["0"]["file"]
      params[:challenge].delete :challenge_files_attributes
    end

    @challenge = current_course.challenges.includes(:challenge_score_levels).find(params[:id])

    if @challenge_files
      @challenge_files.each do |cf|
        @challenge.challenge_files.new(file: cf, filename: cf.original_filename[0..49])
      end
    end

    respond_to do |format|
      if @challenge.update_attributes(params[:challenge])
        format.html { redirect_to @challenge, notice: "Challenge #{@challenge.name} successfully updated" }
        format.json { head :ok }
      else
        # TODO: refactor, see submissions_controller
        @title = "Editing #{@challenge.name}"
        format.html { render action: "edit" }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
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
end
