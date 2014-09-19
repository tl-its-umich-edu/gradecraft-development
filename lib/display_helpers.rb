module DisplayHelpers
  def wrapped_attr(attr, line_width)
    (send(attr) || "").split("\n").collect! do |line|
      line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1<br/>").strip : line
    end * "<br/>"
  end

  def wrapped_name(line_width)
    wrapped_attr(:name, line_width)
  end

  def wrapped_description(line_width)
    wrapped_attr(:description, line_width)
  end
end
