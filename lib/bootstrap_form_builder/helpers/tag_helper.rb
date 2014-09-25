module Tag

  def bootstrap_row
    content_tag(:div, class: "row") { yield }
  end

  def control_group
    content_tag(:div, class: "row") { yield }
  end
end