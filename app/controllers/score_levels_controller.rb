class ScoreLevelsController < ApplicationController

  #Score Levels are used to build structured grade levels that instructors can pick from when grading

  before_filter :ensure_staff?

  def create
    @score_level = current_course.score_levels.new(params[:score_level])
    @score_level.save
  end

  def update
    @score_level = current_course.score_levels.find(params[:id])
    @score_level.update_attributes(params[:score_level])
    respond_with @score_level
  end

  def destroy
    @score_level = current_course.score_levels.find(params[:id])
    @score_level.destroy
  end
end