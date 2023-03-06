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
    "#{preferred_size_class} #{preferred_code_style_class} #{preferred_font_class} #{preferred_font_size_class}"
  end

   def preferred_size_class
    size = Current.user.preferred_size || "medium"
    "size-#{size}"
  end

  def preferred_code_style_class
    code_style = Current.user.preferred_code_style || "dimmed"
    "code-theme-#{code_style}"
  end

  def preferred_theme_class
    theme = Current.user.preferred_theme || "system"
    "#{theme}"
  end

  def preferred_font_class
    font = Current.user.preferred_font || "default"
    "font-#{font}"
  end

  def preferred_font_size_class
    font_size = Current.user.preferred_font_size || "md"
    "text-#{font_size}"
  end
end
