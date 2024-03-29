module ApplicationHelper
  include Pagy::Frontend

  def class_if(condition, klass)
    condition ? klass : ''
  end

  def nav_active(controller, action = nil)
    class_if(params[:controller] == controller && (action.nil? || params[:action] == action), 'nav-active')
  end

  def pretty_date_display(date)
    return '' unless date

    # if (date.year == DateTime.now.year || date.year == DateTime.now.year - 1)
      # date.strftime('%b %d')
    # else
      date.strftime('%b %d, %Y')
    # end
  end

  def preference_classes
    "#{preferred_size_class} #{preferred_code_style_class} #{preferred_font_class} #{sidebar_collapsed} #{preferred_font_size_class}"
  end

   def preferred_size_class
    size = Current.user&.preferred_size || "medium"
    "size-#{size}"
  end

  def preferred_code_style_class
    code_style = Current.user&.preferred_code_style || "dimmed"
    "code-theme-#{code_style}"
  end

  def preferred_theme_class
    theme = Current.user&.preferred_theme || "system"
    "#{theme}"
  end

  def preferred_font_class
    font = Current.user&.preferred_font || "default"
    "reading-font-#{font}"
  end

  def preferred_font_size_class
    font_size = Current.user&.preferred_font_size || "base"
    font_size = "base" if font_size == "md"
    "content-text-#{font_size}"
  end

  def sidebar_collapsed
    (Current.user&.sidebar_collapsed || false) ? 'sidebar-collapsed' : ''
  end

  def seconds_to_display(total_seconds)
    seconds = total_seconds % 60
    minutes = (total_seconds / 60) % 60
    hours = total_seconds / (60 * 60)

    return "#{seconds} seconds" if hours == 0 && minutes == 0
    
    format("%d:%02d", minutes, seconds) if hours == 0

    format("%d:%02d:%02d", hours, minutes, seconds)
  end
end
