module ApplicationHelper
  LONG_TEXT_CONT = '...'
  
  def readable(object) 
    text = object.to_s
    text.gsub!('_', ' ')
    
    text
  end
  
  def active_class(path)
    linkpath = path.split('#')[0]
    "active" if request.fullpath.start_with?(linkpath) && request.fullpath != root_path && !linkpath.empty?
  end
  
 
  def cutlong(text, maxsize=100)
    if text.length > maxsize
      text[0..maxsize-3].rstrip + LONG_TEXT_CONT
    else
      text
    end
  end
  
  def mute(text, mutedcontent = 'none')
    if(!text.methods.include?(:empty?)) then text = text.to_s end
      
    if text.empty?
      content_tag(:span, mutedcontent, class: "muted")
    else 
      if block_given?
        yield
      else
        text
      end
    end
  end
  
  
  
  
end
