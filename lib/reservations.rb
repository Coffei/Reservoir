module ReservationModule
  MAX_OCCURRENCE_COUNT = 100
  include IceCube

  def running?(time = Time.zone.now)
    if(recurs?)
      schedule.occurring_at?(time)
    else
     return start <= time && self.end >= time
    end 
  end
  
  def recurs?
    schedule && !schedule.rrules.empty?
  end  
  
  
  # Returns occurences
  # params- :count specifies max limit of events returned.
  #         :after specifies date for events to be listed from.
  #         :until specifies date for events to be listed upon.
  def occurrences(params={count: MAX_OCCURRENCE_COUNT})
    if(recurs?)
      if(params[:after])
        search_offset = params[:after].localtime.utc_offset - schedule.start_time.localtime.utc_offset
      elsif(params[:until])
        search_offset = params[:until].localtime.utc_offset - schedule.start_time.localtime.utc_offset
      end
    
      #reset schedule to utc
      schedule.start_time.utc
      schedule.end_time.utc
    
      schedules = if(params[:until])
        if(params[:after])
          schedule.occurrences_between(params[:after] - self.schedule.duration + search_offset, params[:until] + search_offset)
        else
          schedule.occurrences(params[:until] + search_offset)
        end
      elsif params[:count]
        if params[:after]
          schedule.next_occurrences(params[:count], params[:after] - self.schedule.duration + search_offset)
        else
          schedule.next_occurrences(params[:count], Time.zone.now - self.schedule.duration)
        end 
      end
      
      if(schedules)
        
        #turn schedules [Time] into self.classes
        schedules.map { |time| duplicate(time - schedule.start_time + (self.start.localtime.utc_offset - time.localtime.utc_offset)) }
      else
        []
      end
    else
      [self]
    end
  end
  
  def next_occurrence(time = Time.zone.now)
    occurrences(count: 1, after: time).first
  end
  
  def duplicate(offset = 0)
    dupl = self.class.new(start: self.start + offset, end: self.end + offset , summary: summary, description: description, scheduleyaml: self.scheduleyaml)
    dupl.id = self.id
    dupl.room_id = self.room_id
    dupl.author_id = self.author_id
    dupl.schedule.start_time = dupl.start
    dupl.schedule.end_time = dupl.end
    
    dupl
  end
  
  module ClassMethods
    def all_occurrences(reservations, params={count: MAX_OCCURRENCE_COUNT})
      result = []
      if(reservations)
        reservations.each do |res|
          if(res.recurs?)
            result.concat res.occurrences(params)
          else
            result << res
          end
        end
      end
      result
    end
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
  
end