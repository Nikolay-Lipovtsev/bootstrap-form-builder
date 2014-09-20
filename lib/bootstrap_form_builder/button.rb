module Button
  def button(options = {})
    
    if options[:tag] != options[:type] ||= "submit"
    content_tag(options[:tag], options[:text], options.slice(:class)) if [:a, :button, :input].include?(options[:tag])
  end
  
  def btn_type(options = {})
    options[:type] ||= "submit"
  end
end