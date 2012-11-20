module ApplicationHelper
  
  def readable(object) 
    text = object.to_s
    text.gsub!('_', ' ')
    
    text
  end
end
