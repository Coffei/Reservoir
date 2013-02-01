class ReservationsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show, :indexByUser, :find, :search, :index_remote]
  DATETIME_FORMAT = Time::DATE_FORMATS[:date_time_nosec]
  layout "wide", only: [:search]
  
  def index
    @room = Room.find(params[:room_id])
    @reservations = Reservation.of(@room).order("\"start\" ASC")
    
    @reservations = @reservations.after(params[:start]) if params[:start]
    @reservations = @reservations.before(params[:end]) if params[:end]
    
    #retrieve events from calendar url
    if(params[:start]) then params[:after] = Time.zone.at(params[:start].to_i) end
    if(params[:end]) then params[:until] = Time.zone.at(params[:end].to_i) end
    @reservations = Reservation.all_occurrences(@reservations, params)
    
    respond_to do |format|
      format.html
      format.js { render :json => @reservations }
      format.json { render :json => @reservations.map { |r| r.as_public_json } }
    end
  end
  
  def index_remote
    @room = Room.find(params[:room_id])
    @reservations = TempReservation.of(@room)
    
    @reservations = @reservations.after(params[:start]) if params[:start]
    @reservations = @reservations.before(params[:end]) if params[:end]
    
    if(params[:start]) then params[:after] = Time.zone.at(params[:start].to_i) end
    if(params[:end]) then params[:until] = Time.zone.at(params[:end].to_i) end
    @reservations = TempReservation.all_occurrences(@reservations, params)
    respond_to do |format|
      format.js { render :json => @reservations }
    end
  end
  
  def indexByUser
    @user = User.find(params[:id])
    
    
     respond_to do |format|
      format.html
      format.js do
        @reservations = Reservation.where(author_id: @user.id).order("\"start\" ASC")

        @reservations = @reservations.after(params[:start]) if params[:start]
        @reservations = @reservations.before(params[:end]) if params[:end]

        if(params[:start]) then params[:after] = Time.zone.at(params[:start].to_i) end
        if(params[:end]) then params[:until] = Time.zone.at(params[:end].to_i) end
        @reservations = Reservation.all_occurrences(@reservations, params)

        render :json => @reservations
      end
      format.json do
        @reservations = Reservation.where(author_id: @user.id).order("\"start\" ASC")

        @reservations = @reservations.after(params[:start]) if params[:start]
        @reservations = @reservations.before(params[:end]) if params[:end]
        
        render :json => @reservations.map { |r| r.as_public_json }
      end 
    end
  end
  
  # mostly as fallback when JS is not allowed
  # TODO: what to do with TempReservations?
  def show
    @reservation = Reservation.find(params[:id])
    
    respond_to do |format|
      format.html
      format.js { render :json => @reservation }
      format.json { render :json => @reservation.as_public_json }
    end
  end
   
  # TODO: Implement recursion!
  def create
    @room = Room.find(params[:room_id])
    
    error = false
    begin
      @reservation = Reservation.new(params[:reservation])
      @reservation.room = @room
      @reservation.author = current_user
      @reservation.start = DateTime.strptime(params[:reservation][:start_string], DATETIME_FORMAT) - DateTime.local_offset
      @reservation.end = DateTime.strptime(params[:reservation][:end_string], DATETIME_FORMAT) - DateTime.local_offset
      
      
      @reservation.schedule = build_schedule(@reservation.start, @reservation.end, params)
        
        
      error = !@reservation.save
    rescue ArgumentError
      @reservation.errors.add(:start_string, "")
      @reservation.errors.add(:end_string, "")
      error = true
    end
    
    if error
      render action: "new"
    else
      flash[:notice] = "Reservation #{@reservation.summary.html_safe} was created!"
      redirect_to @room
    end
  end
  
  def new
    @room = Room.find params[:room_id]
    @reservation = Reservation.new
  end
  
 
  def destroy
    reservation = Reservation.find(params[:id])
    
    reservation.destroy
    
    redirect_to reservation.room
    flash[:notice] = "Reservation #{reservation.summary.html_safe} was deleted!"
  end
  
  def destroymany
    @room = Room.find(params[:room_id])
    ids = params[:deleteids].keys
    deleted = []
    
    ids.each do |id|
      reservation = Reservation.find(id)
      reservation.destroy
      
      deleted << reservation.summary
    end
    
    redirect_to room_reservations_path(@room)
    flash[:notice] = "The following reservations were deleted: " + deleted.map() { |text| text.html_safe }.join(", ")
  end
  
  def edit
    @room = Room.find(params[:room_id])
    @reservation = Reservation.find(params[:id])
    @reservation.start_string = @reservation.start.localtime.strftime(DATETIME_FORMAT)
    @reservation.end_string = @reservation.end.localtime.strftime(DATETIME_FORMAT)
    
    #recurrence options
    if(@reservation.recurs?)
      rule = @reservation.schedule.rrules.first
      params[:interval] = rule.to_hash[:interval].to_s
      
      #frequency
      if(rule.is_a? IceCube::DailyRule)
        params[:frequency] = "1"
      elsif(rule.is_a? IceCube::WeeklyRule)
        params[:frequency] = "2"
        if(rule.to_hash[:validations] && rule.to_hash[:validations][:day])
          params[:weekday] = rule.to_hash[:validations][:day].map(&:to_s)
        end
      elsif(rule.is_a? IceCube::MonthlyRule)
        params[:frequency] = "3"
      elsif(rule.is_a? IceCube::YearlyRule)
        params[:frequency] = "4"
        if(rule.to_hash[:validations] && rule.to_hash[:validations][:month_of_year])
          params[:yearmonths] = rule.to_hash[:validations][:month_of_year].map(&:to_s) 
        end
      end
    
      #until, count
      if(rule.until_time)
        params[:endtype] = "1"
        params[:until] =  rule.until_time.to_s :date_time_nosec
      elsif(rule.occurrence_count)
        params[:endtype] = "2"
        params[:maxcount] = rule.occurrence_count.to_s
      end
    end
    
  end
  
  # TODO: revise recurrence
  def update
    @room = Room.find(params[:room_id])
    error = false
    
    begin
      @reservation = Reservation.find(params[:id])
      @reservation.assign_attributes(params[:reservation])
      @reservation.author = current_user if params[:assign_to_me]
      @reservation.start = DateTime.strptime(params[:reservation][:start_string], DATETIME_FORMAT) - DateTime.local_offset
      @reservation.end = DateTime.strptime(params[:reservation][:end_string], DATETIME_FORMAT) - DateTime.local_offset
      
      #recurrence
      @reservation.schedule = build_schedule(@reservation.start, @reservation.end, params)
      
      error = !@reservation.save
    rescue ArgumentError
      @reservation.errors.add(:start_string,"")
      @reservation.errors.add(:end_string,"")
      error = true
    end
    
    if error
      render action: "edit"
    else
      flash[:notice] = "Reservation #{@reservation.summary.html_safe} was updated!"
      redirect_to @reservation.room
    end
  end
  
  def find
    @reservation = Reservation.new
    @rooms = Room.all.insert(0, Room.new(name: "--no particular room--", id: nil))
  end
  
  def search
    room = params[:reservation].delete(:room)
    @reservation = Reservation.new(params[:reservation])
    search = @reservation
    search.room_id = room
    
    if search.summary.empty? && search.start_string.empty? && search.end_string.empty? && search.description.empty?
      flash[:error] = "Enter some search parameters first!"
      
      @rooms = Room.all.insert(0, Room.new(name: "--no particular room--", id: nil))
      render action: "find"
    else
      begin
        search.start = Time.zone.at((DateTime.strptime(params[:reservation][:start_string], DATETIME_FORMAT) - DateTime.local_offset - 1.minute).to_i) unless search.start_string.empty?
        search.end = Time.zone.at((DateTime.strptime(params[:reservation][:end_string], DATETIME_FORMAT) - DateTime.local_offset + 1.minute).to_i) unless search.end_string.empty?
       
        if search.start_string.empty? || search.end_string.empty? || (search.start <= search.end)
          @reservations = Reservation.order("\"start\" ASC")
        
          @reservations = @reservations.where("LOWER(summary) LIKE LOWER(?)", '%' + search.summary + '%') unless search.summary.empty?
          @reservations = @reservations.where("LOWER(description) LIKE LOWER(?)", '%' + search.description + '%') unless search.description.empty?
          @reservations = @reservations.after(search.start.to_i) unless search.start_string.empty?
          @reservations = @reservations.before(search.end.to_i) unless search.end_string.empty?
          @reservations = @reservations.where("room_id = ?", search.room_id) unless search.room_id == nil
          
          @temps = TempReservation.order("\"start\" ASC")
          @temps = @temps.where("LOWER(summary) LIKE LOWER(?)", '%' + search.summary + '%') unless search.summary.empty?
          @temps = @temps.where("LOWER(description) LIKE LOWER(?)", '%' + search.description + '%') unless search.description.empty?
          @temps = @temps.after(search.start.to_i) unless search.start_string.empty?
          @temps = @temps.before(search.end.to_i) unless search.end_string.empty?
          @temps = @temps.where("room_id = ?", search.room_id) unless search.room_id == nil
          
          @reservations.concat(@temps)
          
          unless(search.start_string.empty?)
            unless(search.end_string.empty?)
              @reservations = @reservations.select { |res| !res.recurs? || res.schedule.occurs_between?(search.start - res.schedule.duration, search.end) }
            else
              @reservations = @reservations.select { |res| !res.recurs? || !res.schedule.next_occurrence(search.start - res.schedule.duration).nil? }
            end
          else
            unless(search.end_string.empty?)
              @reservations = @reservations.select { |res| !res.recurs? || res.start <= search.end }
            end
          end
          
          @reservations.sort_by!(&:start)
        else
          @reservation.errors.add(:start_string, "must be before end")
          @reservation.errors.add(:end_string, "must be after start")
          
          @rooms = Room.all.insert(0, Room.new(name: "--no particular room--", id: nil))
          render action: "find"
        end
        
      rescue ArgumentError
        @reservation.errors.add(:start_string,"")
        @reservation.errors.add(:end_string,"")
        
        @rooms = Room.all.insert(0, Room.new(name: "--no particular room--", id: nil))
        render action: "find"
      end
    end
  end
  
  private

  def build_schedule(start_time, end_time, params)
    schedule = nil
    if(params[:frequency] && !params[:frequency].empty? && params[:frequency] != "0")

      #parse interval
      interval = params[:interval].to_i
      interval = 1 if interval <= 0

      schedule = IceCube::Schedule.new(start_time, end_time: end_time)

      case params[:frequency]
      when "1"; rule = IceCube::Rule.daily(interval)
      when "2"; rule = IceCube::Rule.weekly(interval)
      when "3"; rule = IceCube::Rule.monthly(interval)
      when "4"; rule = IceCube::Rule.yearly(interval)
      end

      if(params[:frequency]=="2" && params[:weekday])
        days = params[:weekday].map(&:to_i)
      rule.day(*days)
      end

      if(params[:frequency]=="4" && params[:yearmonths])
        months = params[:yearmonths].map(&:to_i)
      rule.month_of_year(*months)
      end

      #until, count
      if(params[:endtype] && params[:endtype] == "1")
        until_time = Time.zone.at((DateTime.strptime(params[:until], DATETIME_FORMAT) - DateTime.local_offset).to_i)
        # on error apply no until
        if(until_time.utc >= @reservation.end.utc)
        rule.until(until_time)
        end
      end

      if(params[:endtype] && params[:endtype] == "2")
        count = params[:maxcount].to_i
        # on error don't apply max-count
        if(count > 0)
        rule.count(count)
        end
      end

      schedule.add_recurrence_rule rule
    end

    schedule
  end
end
