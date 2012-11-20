module ApplicationHelper
  
  def readable(object) 
    text = object.to_s
    text.gsub!('_', ' ')
    
    text
  end
  
  def active_class(path)
    linkpath = path.split('#')[0]
    "active" if request.fullpath.start_with?(linkpath) && request.fullpath != root_path && !linkpath.empty?
  end
end
