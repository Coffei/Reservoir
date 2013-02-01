module ReservationModule
  MAX_OCCURRENCE_COUNT = 100
  include IceCube

  def running?
    if(recurs?)
      schedule.occurring_at?(Time.zone.now)
    else
     return start <= Time.zone.now && self.end >= Time.zone.now
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
      schedules = if(params[:until])
        if(params[:after])
          schedule.occurrences_between(params[:after] - self.schedule.duration, params[:until])
        else
          schedule.occurrences(params[:until])
        end
      elsif params[:count]
        if params[:after]
          schedule.next_occurrences(params[:count], params[:after] - self.schedule.duration)
        else
          schedule.next_occurrences(params[:count])
        end 
      end
      
      if(schedules)
        #turn schedules [Time] into self.classes
        schedules.map { |time| duplicate(time - schedule.start_time + (self.start.localtime.utc_offset - time.localtime.utc_offset)) }
      end
    end
  end
  
  def duplicate(offset = 0)
    dupl = self.class.new(start: self.start + offset, end: self.end + offset , summary: summary, description: description, scheduleyaml: self.scheduleyaml)
    dupl.id = self.id
    dupl.room_id = self.room_id
    dupl.author_id = self.author_id
    
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