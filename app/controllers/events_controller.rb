class EventsController < ApplicationController
  
  before_filter :ensure_staff?

  def index
    @events = current_course.events
    @title = "#{current_course.name} Calendar Events"
  end

  def show
    @event = current_course.events.find(params[:id])
    @title = @event.name
  end

  def new
    @event = current_course.events.new
    @title = "Create a New Calendar Event"
  end

  def edit
    @event = current_course.events.find(params[:id])
    @title = "Edit New Calendar Event"
  end

  def create
    @event = current_course.events.new(params[:event])
    flash[:notice] = 'Event was successfully created.' if @event.save
    respond_with(@event)
  end

  def update
    @event = Event.find(params[:id])
    flash[:notice] = 'Event was successfully updated.' if @event.update(params[:event])
    respond_with(@event)
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    respond_with(@event)
  end

end
