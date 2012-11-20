module RoomsHelper
  
  def mute(text)
    if text.empty?
      content_tag(:span, 'none', class: "muted")
    else 
      text
    end
  end
  
end
