module RoomsHelper
  
  
  def status(next_reservation)
    if next_reservation
      if next_reservation.is_running || next_reservation.start.localtime - 10.minutes <= Time.now
        content_tag(:span, 'Occupied', class: "label label-big label-important") + content_tag(:small, " #{next_reservation.summary}" + 
           " ends in #{time_diff_in_natural_language(Time.now, next_reservation.end.localtime)}")
      else
         content_tag(:span, 'Free', class: "label label-big label-success") + " #{next_reservation.summary}" + 
           " starts in #{time_diff_in_natural_language(Time.now, next_reservation.start.localtime)}"
      end
    else
      content_tag(:span, 'no event in the next 14 days', class: "muted")
    end
  end
  
  def time_diff_in_natural_language(from_time, to_time)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_seconds = ((to_time - from_time).abs).round
    components = []
  
    %w(day hour minute).each do |interval|
      # For each interval type, if the amount of time remaining is greater than
      # one unit, calculate how many units fit into the remaining time.
      if distance_in_seconds >= 1.send(interval)
        delta = (distance_in_seconds / 1.send(interval)).floor
        distance_in_seconds -= delta.send(interval)
        components << pluralize(delta, interval)
      end
    end
  
    components.join(", ")
  end
  
end
