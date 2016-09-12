class EventsController < ApplicationController

  def show
    @event = Event.new
    @auth_link = @@cal.authorize_url
  end

  def callback
    unless params[:code].blank?
      begin
        @@cal.login_with_auth_code(params[:code])
        session[:token] = params[:code]
        flash.now[:notice] = 'Authorize successful!'
        flash.keep
        redirect_to action:  'show'
      rescue StandardError => e
        flash.now[:error] = 'Authorize unsuccessful!'
        flash.keep
        redirect_to action:  'show'
      end
    else
      flash.now[:error] = 'Authorize unsuccessful!'
      flash.keep
      redirect_to action:  'show'
    end
  end

  def create
    #init object event
    @event = Event.new(event_params)
    if @event.valid?
      #check access
      if @@cal.access_token.nil?
        flash.now[:error_event] = 'Add event unsuccessful, please add event again !!'
        flash.keep
        redirect_to @@cal.authorize_url.to_s
      else
        begin
          #create new event
          @@cal.create_event do |e|
            e.title = @event.title
            unless @event.start_time.nil? || @event.start_time.blank?
              e.start_time = @event.start_time.to_time
            else
              e.start_time = Time.now
            end
            unless @event.end_time.nil? || @event.end_time.blank?
              e.end_time = @event.end_time.to_time
            end
            e.description = @event.description
            e.location = @event.location
            flash.now[:notice_event] = 'Add event successful!'
            flash.keep
            redirect_to action:  'show'
          end
        rescue StandardError => e
          flash.now[:error_event] = 'Add event unsuccessful, please add event again !!'
          flash.keep
          redirect_to @@cal.authorize_url.to_s
        end
      end
    else
      flash.now[:error_event] = @event.errors.full_messages[0]
      flash.keep
      redirect_to action:  'show'
    end
  end

  private
  def event_params
    params.require(:event).permit(
        :title,
        :location,
        :start_time,
        :end_time,
        :description
    )
  end
end
