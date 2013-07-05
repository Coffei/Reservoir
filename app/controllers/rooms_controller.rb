class RoomsController < ApplicationController
  
  before_filter :authenticate_user!, except: [:index, :show, :start_remotecal_worker]
  
  def index
    @rooms = Room.order("location ASC, name ASC")
    
    respond_to do |format|
      format.html
      format.json { render json: @rooms }
    end
  end
  
  def destroy
    room = Room.find(params[:id])
    
    #delete all reservations and temp-reservations
    room.reservations.destroy_all
    TempReservation.of(room).delete_all
    room.destroy
    
    redirect_to rooms_path
    flash[:info] = "Room #{room.name.html_safe} was deleted."
  end
  
  def new
    @room = Room.new
  end
  
  def create
    @room = Room.new(params[:room])
    if @room.save
      Delayed::Job.enqueue(RemoteCalendar.new(@room.id))
      flash[:info] = "Room #{@room.name.html_safe} was created."
      redirect_to @room
    else
      render action: "new"
    end
    
  end
  
  def edit
    @room = Room.find(params[:id])
  end
  
  def update
    @room = Room.find(params[:id])
    old_cal_url = @room.cal_url
    if(@room.update_attributes(params[:room]))
      if(old_cal_url != @room.cal_url)
        Delayed::Job.enqueue(RemoteCalendar.new(@room.id))
      end
      flash[:info] = "Room #{@room.name.html_safe} was updated."
      redirect_to @room
    else
      render action: "edit"
    end
  end
  
  def show
    @room = Room.find(params[:id])
    rnd_temp = TempReservation.of(@room).first
    @last_remote_update = (rnd_temp)? rnd_temp.updated_at.localtime : nil
 
    now = Time.zone.now
    reservations = Reservation.of(@room).between(now, now + 14.days).map(&:next_occurrence)
    reservations.concat(TempReservation.of(@room).between(now, now + 14.days).map(&:next_occurrence))
    reservations.delete_if { |el| el==nil } 
    @next_reservation = reservations.min_by(&:start)
    
    #new reservation for form
    @reservation = Reservation.new
    @reservation.start_string = Time.zone.now.localtime.to_s :date_time_nosec
    @reservation.end_string = (Time.zone.now.localtime + 30.minutes).to_s :date_time_nosec
    
     #pending jobs
    jobs = ActiveRecord::Base.connection.execute("SELECT * FROM delayed_jobs ORDER BY run_at")
    transform_jobs(jobs, @room.id)
   
   
    @update_jobs = jobs.select {|job| job["handler"].is_a? RemoteCalendar }
    @failed_jobs = jobs.select {|job| job["last_error"] != nil}
    
    @failed_ratio = 0
    @failed_ratio = @failed_jobs.size * 100 / (@update_jobs.size) if (@update_jobs.size) > 0
  
    respond_to do |format|
      format.html
      format.json { render json: @room }
    end
  end
  
  def start_remotecal_worker
    if(params[:room_id])
      Delayed::Job.enqueue(RemoteCalendar.new(params[:room_id], false))
      flash[:info] = "Remote calendar update was scheduled and will be finished soon."
      
      params[:id] = params[:room_id]
      redirect_to action: "show", id: params[:room_id]
      
    else
      Delayed::Job.enqueue(RemoteCalendar.new)

      flash[:info] = "Remote calendar update for all rooms was scheduled. "
      
      redirect_to action: "index"
    end

  end
  
  private
  def transform_jobs(jobs, room_id=nil)
    jobs.each {|job| job["handler"] = YAML.load(job["handler"])}
   
   if(room_id)
      #filter jobs by room_id
      jobs.keep_if { |job| job["handler"].room_id == room_id.to_s}
    end
  end
end
